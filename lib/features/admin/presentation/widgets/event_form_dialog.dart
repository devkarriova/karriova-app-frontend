import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/event_model.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

/// Dialog for creating/editing events with a generic form
class EventFormDialog extends StatefulWidget {
  final EventModel? event;

  const EventFormDialog({super.key, this.event});

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _locationController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _virtualPlatformController;
  late final TextEditingController _virtualLinkController;
  late final TextEditingController _maxAttendeesController;
  late final TextEditingController _feeController;
  late final TextEditingController _organizerNameController;
  late final TextEditingController _organizerEmailController;
  late final TextEditingController _tagsController;

  String _eventType = 'in_person';
  String? _categoryId;
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isRegistrationRequired = true;
  bool _isPublic = true;
  String _currency = 'USD';

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;

    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    _shortDescController = TextEditingController(text: event?.shortDescription ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _addressController = TextEditingController(text: event?.address ?? '');
    _cityController = TextEditingController(text: event?.city ?? '');
    _countryController = TextEditingController(text: event?.country ?? '');
    _virtualPlatformController = TextEditingController(text: event?.virtualPlatform ?? '');
    _virtualLinkController = TextEditingController(text: event?.virtualLink ?? '');
    _maxAttendeesController = TextEditingController(
      text: event?.maxAttendees?.toString() ?? '',
    );
    _feeController = TextEditingController(
      text: event?.registrationFee.toString() ?? '0',
    );
    _organizerNameController = TextEditingController(text: event?.organizerName ?? '');
    _organizerEmailController = TextEditingController(text: event?.organizerEmail ?? '');
    _tagsController = TextEditingController(text: event?.tags.join(', ') ?? '');

    if (event != null) {
      _eventType = event.eventType;
      _categoryId = event.categoryId;
      _startDate = event.startTime;
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endDate = event.endTime;
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      _isRegistrationRequired = event.isRegistrationRequired;
      _isPublic = event.isPublic;
      _currency = event.currency;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _shortDescController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _virtualPlatformController.dispose();
    _virtualLinkController.dispose();
    _maxAttendeesController.dispose();
    _feeController.dispose();
    _organizerNameController.dispose();
    _organizerEmailController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state.formStatus == FormStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfoSection(),
                        const SizedBox(height: 24),
                        _buildDateTimeSection(),
                        const SizedBox(height: 24),
                        _buildLocationSection(),
                        const SizedBox(height: 24),
                        _buildRegistrationSection(),
                        const SizedBox(height: 24),
                        _buildOrganizerSection(),
                        const SizedBox(height: 24),
                        _buildTagsSection(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.add_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit Event' : 'Create New Event',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: _inputDecoration('Event Title *'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _shortDescController,
          decoration: _inputDecoration('Short Description'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: _inputDecoration('Full Description *'),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            return DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: _inputDecoration('Category'),
              items: state.categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _categoryId = value);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Date & Time'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DateTimePicker(
                label: 'Start Date',
                value: dateFormat.format(_startDate),
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DateTimePicker(
                label: 'Start Time',
                value: _startTime.format(context),
                onTap: () => _selectTime(true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DateTimePicker(
                label: 'End Date',
                value: dateFormat.format(_endDate),
                onTap: () => _selectDate(false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DateTimePicker(
                label: 'End Time',
                value: _endTime.format(context),
                onTap: () => _selectTime(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Location'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _eventType,
          decoration: _inputDecoration('Event Type'),
          items: const [
            DropdownMenuItem(value: 'in_person', child: Text('In Person')),
            DropdownMenuItem(value: 'virtual', child: Text('Virtual')),
            DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
          ],
          onChanged: (value) {
            setState(() => _eventType = value ?? 'in_person');
          },
        ),
        const SizedBox(height: 16),
        if (_eventType != 'virtual') ...[
          TextFormField(
            controller: _locationController,
            decoration: _inputDecoration('Venue Name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: _inputDecoration('Address'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: _inputDecoration('City'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  decoration: _inputDecoration('Country'),
                ),
              ),
            ],
          ),
        ],
        if (_eventType != 'in_person') ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _virtualPlatformController,
            decoration: _inputDecoration('Virtual Platform (e.g., Zoom, Teams)'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _virtualLinkController,
            decoration: _inputDecoration('Virtual Meeting Link'),
          ),
        ],
      ],
    );
  }

  Widget _buildRegistrationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Registration'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: const Text('Registration Required'),
                value: _isRegistrationRequired,
                onChanged: (value) {
                  setState(() => _isRegistrationRequired = value);
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Public Event'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() => _isPublic = value);
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _maxAttendeesController,
                decoration: _inputDecoration('Max Attendees (optional)'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _feeController,
                      decoration: _inputDecoration('Registration Fee'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: _inputDecoration(''),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                        DropdownMenuItem(value: 'INR', child: Text('INR')),
                      ],
                      onChanged: (value) {
                        setState(() => _currency = value ?? 'USD');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganizerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Organizer Info'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _organizerNameController,
                decoration: _inputDecoration('Organizer Name'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _organizerEmailController,
                decoration: _inputDecoration('Organizer Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tags'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _tagsController,
          decoration: _inputDecoration('Tags (comma-separated)'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final isLoading = state.formStatus == FormStatus.loading;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (state.formError != null)
                Expanded(
                  child: Text(
                    state.formError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEditing ? 'Update Event' : 'Create Event'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final initialTime = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'short_description': _shortDescController.text.isEmpty
            ? null
            : _shortDescController.text,
        'category_id': _categoryId,
        'event_type': _eventType,
        'location': _locationController.text.isEmpty
            ? null
            : _locationController.text,
        'address': _addressController.text.isEmpty
            ? null
            : _addressController.text,
        'city': _cityController.text.isEmpty ? null : _cityController.text,
        'country': _countryController.text.isEmpty
            ? null
            : _countryController.text,
        'is_virtual': _eventType != 'in_person',
        'virtual_platform': _virtualPlatformController.text.isEmpty
            ? null
            : _virtualPlatformController.text,
        'virtual_link': _virtualLinkController.text.isEmpty
            ? null
            : _virtualLinkController.text,
        'start_time': startDateTime.toIso8601String(),
        'end_time': endDateTime.toIso8601String(),
        'timezone': 'UTC',
        'max_attendees': _maxAttendeesController.text.isEmpty
            ? null
            : int.tryParse(_maxAttendeesController.text),
        'is_registration_required': _isRegistrationRequired,
        'registration_fee': double.tryParse(_feeController.text) ?? 0,
        'currency': _currency,
        'is_public': _isPublic,
        'organizer_name': _organizerNameController.text.isEmpty
            ? null
            : _organizerNameController.text,
        'organizer_email': _organizerEmailController.text.isEmpty
            ? null
            : _organizerEmailController.text,
        'tags': _tagsController.text.isEmpty
            ? <String>[]
            : _tagsController.text.split(',').map((t) => t.trim()).toList(),
      };

      if (isEditing) {
        context.read<AdminBloc>().add(
              UpdateEventEvent(widget.event!.id, eventData),
            );
      } else {
        context.read<AdminBloc>().add(CreateEventEvent(eventData));
      }
    }
  }
}

/// Date/Time picker widget
class _DateTimePicker extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimePicker({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
