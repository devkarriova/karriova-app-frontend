import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Firebase Phone Authentication Service - OTP only
/// This service handles phone number verification using Firebase Auth
/// without creating a persistent user session
class FirebaseOtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _verificationId;
  int? _resendToken;
  ConfirmationResult? _webConfirmationResult; // For web platform
  
  /// Get the current verification ID (used for OTP verification)
  String? get verificationId => _verificationId;
  
  /// Send OTP to the specified phone number
  /// [phoneNumber] must be in E.164 format (e.g., +1234567890)
  /// 
  /// Returns a completer that completes when:
  /// - OTP is sent successfully (returns true)
  /// - Instant verification happens (returns true)
  /// - An error occurs (throws exception)
  Future<OtpSendResult> sendOtp(String phoneNumber) async {
    // For web platform, use signInWithPhoneNumber which handles reCAPTCHA
    if (kIsWeb) {
      return _sendOtpWeb(phoneNumber);
    }
    
    // For mobile platforms, use verifyPhoneNumber
    return _sendOtpMobile(phoneNumber);
  }
  
  /// Web-specific OTP sending with reCAPTCHA
  Future<OtpSendResult> _sendOtpWeb(String phoneNumber) async {
    try {
      _webConfirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
      return OtpSendResult(
        success: true,
        autoVerified: false,
        message: 'OTP sent successfully',
      );
    } on FirebaseAuthException catch (e) {
      throw OtpException(_getErrorMessage(e), e.code);
    } catch (e) {
      throw OtpException('Failed to send OTP: ${e.toString()}', 'unknown');
    }
  }
  
  /// Mobile-specific OTP sending
  Future<OtpSendResult> _sendOtpMobile(String phoneNumber) async {
    final completer = Completer<OtpSendResult>();
    
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      
      // Called when the verification is done instantly (auto-retrieval)
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification happened (Android only)
        // We can sign in to verify, then immediately sign out
        try {
          await _auth.signInWithCredential(credential);
          await _auth.signOut(); // Sign out immediately - we only want OTP verification
          if (!completer.isCompleted) {
            completer.complete(OtpSendResult(
              success: true,
              autoVerified: true,
              message: 'Phone number automatically verified',
            ));
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
      
      // Called when Firebase sends an SMS with OTP
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) {
          completer.complete(OtpSendResult(
            success: true,
            autoVerified: false,
            message: 'OTP sent successfully',
            verificationId: verificationId,
          ));
        }
      },
      
      // Called when auto-retrieval times out
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        // Don't complete here, codeSent would have already completed
      },
      
      // Called when verification fails
      verificationFailed: (FirebaseAuthException e) {
        String message;
        switch (e.code) {
          case 'invalid-phone-number':
            message = 'Invalid phone number format';
            break;
          case 'too-many-requests':
            message = 'Too many requests. Please try again later';
            break;
          case 'quota-exceeded':
            message = 'SMS quota exceeded. Please try again later';
            break;
          default:
            message = e.message ?? 'Failed to send OTP';
        }
        if (!completer.isCompleted) {
          completer.completeError(OtpException(message, e.code));
        }
      },
    );
    
    return completer.future;
  }
  
  /// Verify the OTP code entered by user
  /// Returns true if verification is successful
  Future<bool> verifyOtp(String smsCode) async {
    // For web platform
    if (kIsWeb) {
      return _verifyOtpWeb(smsCode);
    }
    
    // For mobile platforms
    return _verifyOtpMobile(smsCode);
  }
  
  /// Web-specific OTP verification
  Future<bool> _verifyOtpWeb(String smsCode) async {
    if (_webConfirmationResult == null) {
      throw OtpException('No verification in progress. Send OTP first.', 'no-verification');
    }
    
    try {
      await _webConfirmationResult!.confirm(smsCode);
      
      // Immediately sign out - we only use Firebase for OTP verification
      await _auth.signOut();
      
      // Clear verification state
      _webConfirmationResult = null;
      
      return true;
    } on FirebaseAuthException catch (e) {
      throw OtpException(_getErrorMessage(e), e.code);
    } catch (e) {
      throw OtpException('Failed to verify OTP: ${e.toString()}', 'unknown');
    }
  }
  
  /// Mobile-specific OTP verification
  Future<bool> _verifyOtpMobile(String smsCode) async {
    if (_verificationId == null) {
      throw OtpException('No verification in progress. Send OTP first.', 'no-verification');
    }
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      
      // Sign in to verify the code
      await _auth.signInWithCredential(credential);
      
      // Immediately sign out - we only use Firebase for OTP verification
      // The actual user account is managed by our backend
      await _auth.signOut();
      
      // Clear verification state
      _verificationId = null;
      
      return true;
    } on FirebaseAuthException catch (e) {
      throw OtpException(_getErrorMessage(e), e.code);
    }
  }
  
  /// Get user-friendly error message from Firebase exception
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      case 'invalid-verification-code':
        return 'Invalid OTP code';
      case 'session-expired':
        return 'OTP has expired. Please request a new one';
      case 'web-context-cancelled':
        return 'Verification cancelled';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Please try again';
      default:
        return e.message ?? 'Failed to verify phone number';
    }
  }
  
  /// Resend OTP to the same phone number
  Future<OtpSendResult> resendOtp(String phoneNumber) async {
    return sendOtp(phoneNumber);
  }
  
  /// Clear any pending verification
  void clearVerification() {
    _verificationId = null;
    _resendToken = null;
    _webConfirmationResult = null;
  }
}

/// Result of sending OTP
class OtpSendResult {
  final bool success;
  final bool autoVerified;
  final String message;
  final String? verificationId;
  
  OtpSendResult({
    required this.success,
    required this.autoVerified,
    required this.message,
    this.verificationId,
  });
}

/// Exception thrown during OTP operations
class OtpException implements Exception {
  final String message;
  final String code;
  
  OtpException(this.message, this.code);
  
  @override
  String toString() => message;
}
