import 'package:geolocator/geolocator.dart';
import '../models/hospital.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? type; // 'text', 'health_tip', 'facility_info'

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type,
  });
}

class ChatbotService {
  static const double NEARBY_DISTANCE_KM = 50;

  static final List<String> _greetings = [
    'Hello! 👋 How can I assist you today?',
    'Hi there! 👋 What can I help you with?',
    'Welcome! 👋 How can I help you?',
    'Greetings! 👋 What brings you here?',
  ];

  static final Map<String, dynamic> _healthKnowledge = {
    'fever': {
      'guidance':
          'Fever is a temporary increase in body temperature. Here\'s professional guidance:\n\n'
          '🌡️ **When to be concerned:**\n'
          '• Temperature above 40.5°C (104.9°F)\n'
          '• Fever lasting more than 3 days\n'
          '• Severe symptoms like difficulty breathing or chest pain\n'
          '• Persistent high fever in children under 3 months\n\n'
          '💊 **Self-care measures:**\n'
          '• Stay hydrated - drink plenty of water\n'
          '• Rest and get adequate sleep\n'
          '• Use cool compresses on forehead\n'
          '• Take over-the-counter antipyretics (Paracetamol/Ibuprofen)\n'
          '• Wear light clothing\n\n'
          '⚠️ **Seek immediate medical care if:**\n'
          '• Temperature exceeds 40.5°C repeatedly\n'
          '• Fever accompanied by rash, confusion, or severe headache\n'
          '• Unable to take fluids or medications\n\n'
          '💡 *This is general guidance. Always consult a qualified healthcare provider.*',
      'keywords': ['fever', 'temperature', 'high temp', 'running temperature'],
      'facilities': ['General Practice', 'Internal Medicine', 'Urgent Care'],
    },
    'cough': {
      'guidance':
          'A cough can be caused by various conditions. Professional guidance:\n\n'
          '🫁 **Types to note:**\n'
          '• Dry cough - may indicate viral infection or irritation\n'
          '• Productive cough - with phlegm, often bacterial\n'
          '• Persistent cough - lasting 2+ weeks\n\n'
          '💊 **Self-care measures:**\n'
          '• Stay hydrated with warm fluids\n'
          '• Use honey for throat soothing (avoid for infants under 1 year)\n'
          '• Use humidifier or breathe steam\n'
          '• Avoid irritants like smoke and strong smells\n'
          '• Rest adequately\n\n'
          '⚠️ **Seek medical attention if:**\n'
          '• Cough lasts more than 3 weeks\n'
          '• Accompanied by fever, chest pain, or bloody phlegm\n'
          '• Difficulty breathing (dyspnea)\n'
          '• Signs of pneumonia or bronchitis\n\n'
          '💡 *Persistent cough may require professional diagnosis.*',
      'keywords': ['cough', 'coughing', 'throat', 'congestion'],
      'facilities': ['General Practice', 'Respiratory Medicine', 'Pulmonology'],
    },
    'headache': {
      'guidance':
          'Headaches can vary greatly in cause and severity. Professional guidance:\n\n'
          '🧠 **Common types:**\n'
          '• Tension headache - pressure/tightness around head\n'
          '• Migraine - throbbing, often one-sided\n'
          '• Cluster headache - intense around eyes\n\n'
          '💊 **Self-care measures:**\n'
          '• Rest in a quiet, dark room\n'
          '• Apply cold or warm compress\n'
          '• Stay well-hydrated\n'
          '• Manage stress through relaxation\n'
          '• Take pain relievers (Paracetamol/Ibuprofen)\n'
          '• Regular sleep schedule\n\n'
          '⚠️ **Seek immediate care if:**\n'
          '• Sudden severe headache (worst of your life)\n'
          '• Headache with fever, stiff neck, confusion\n'
          '• Vision changes or weakness\n'
          '• After head trauma\n'
          '• Frequent headaches affecting daily life\n\n'
          '💡 *Persistent headaches warrant professional evaluation.*',
      'keywords': ['headache', 'head pain', 'migraine', 'headaches'],
      'facilities': ['General Practice', 'Neurology', 'Internal Medicine'],
    },
    'body pain': {
      'guidance':
          'Body pain can have multiple causes. Professional guidance:\n\n'
          '💪 **Common causes:**\n'
          '• Muscle strain from overexertion\n'
          '• Viral infections (flu, cold)\n'
          '• Poor posture or ergonomics\n'
          '• Stress and anxiety\n\n'
          '💊 **Self-care measures:**\n'
          '• Rest the affected area\n'
          '• Apply hot or cold therapy\n'
          '• Take over-the-counter pain relievers\n'
          '• Gentle stretching and exercise\n'
          '• Improve posture and ergonomics\n'
          '• Practice stress management\n\n'
          '⚠️ **Seek medical attention if:**\n'
          '• Pain is severe or sudden\n'
          '• Associated with fever or other symptoms\n'
          '• Persists for more than a week\n'
          '• Limits normal movement or activities\n'
          '• Following an injury or accident\n\n'
          '💡 *Professional diagnosis helps identify underlying causes.*',
      'keywords': ['body pain', 'pain', 'ache', 'muscle pain', 'joint pain'],
      'facilities': ['General Practice', 'Orthopedics', 'Physiotherapy'],
    },
    'nausea': {
      'guidance':
          'Nausea can indicate various conditions. Professional guidance:\n\n'
          '🤢 **Common causes:**\n'
          '• Food poisoning or stomach issues\n'
          '• Viral infections\n'
          '• Motion sickness\n'
          '• Medication side effects\n'
          '• Anxiety or stress\n\n'
          '💊 **Self-care measures:**\n'
          '• Sip clear fluids slowly\n'
          '• Rest in comfortable position\n'
          '• Avoid strong odors and heavy foods\n'
          '• Try ginger or peppermint tea\n'
          '• Eat small, frequent meals\n'
          '• Get fresh air\n\n'
          '⚠️ **Seek medical help if:**\n'
          '• Unable to keep fluids down (risk of dehydration)\n'
          '• Severe vomiting or nausea lasting > 2 days\n'
          '• Associated with severe abdominal pain\n'
          '• Signs of dehydration\n'
          '• Following medication\n\n'
          '💡 *Persistent nausea needs professional evaluation.*',
      'keywords': ['nausea', 'feel sick', 'vomiting', 'queasy'],
      'facilities': [
        'General Practice',
        'Gastroenterology',
        'Internal Medicine',
      ],
    },
    'dizziness': {
      'guidance':
          'Dizziness can have various causes. Professional guidance:\n\n'
          '🌪️ **Types:**\n'
          '• Vertigo - sensation of spinning\n'
          '• Lightheadedness - feeling faint\n'
          '• Loss of balance\n\n'
          '💊 **Self-care measures:**\n'
          '• Sit or lie down immediately\n'
          '• Move slowly and deliberately\n'
          '• Avoid sudden position changes\n'
          '• Stay hydrated\n'
          '• Avoid driving until resolved\n'
          '• Rest adequately\n\n'
          '⚠️ **Seek emergency care if:**\n'
          '• Severe dizziness with chest pain\n'
          '• Accompanied by difficulty breathing\n'
          '• Following a head injury\n'
          '• With confusion or loss of consciousness\n'
          '• Severe persistent dizziness\n\n'
          '💡 *Recurrent dizziness requires professional diagnosis.*',
      'keywords': ['dizzy', 'dizziness', 'vertigo', 'lightheaded', 'faint'],
      'facilities': [
        'General Practice',
        'Neurology',
        'ENT (Ear, Nose, Throat)',
      ],
    },
    'allergy': {
      'guidance':
          'Allergies are immune responses to allergens. Professional guidance:\n\n'
          '🧬 **Common symptoms:**\n'
          '• Sneezing and nasal congestion\n'
          '• Itchy, watery eyes\n'
          '• Skin reactions or hives\n'
          '• Respiratory issues\n\n'
          '💊 **Self-care measures:**\n'
          '• Identify and avoid allergens\n'
          '• Take antihistamines\n'
          '• Use saline nasal drops\n'
          '• Keep environment clean\n'
          '• Wear protective gear in dusty areas\n'
          '• Regular personal hygiene\n\n'
          '⚠️ **Seek emergency care if:**\n'
          '• Anaphylaxis symptoms (severe reaction)\n'
          '• Difficulty breathing or throat swelling\n'
          '• Severe skin reactions\n'
          '• Loss of consciousness\n\n'
          '💡 *Allergy testing helps identify triggers. Consult allergist.*',
      'keywords': ['allergy', 'allergies', 'allergic', 'itching', 'itchy'],
      'facilities': ['General Practice', 'Allergology', 'Dermatology'],
    },
    'wound': {
      'guidance':
          'Proper wound care is essential for healing. Professional guidance:\n\n'
          '🩹 **Immediate care:**\n'
          '• Stop bleeding with direct pressure\n'
          '• Clean with gentle flowing water\n'
          '• Apply antiseptic if available\n'
          '• Cover with sterile bandage\n\n'
          '💊 **Wound care measures:**\n'
          '• Keep clean and dry\n'
          '• Change dressing regularly\n'
          '• Watch for signs of infection\n'
          '• Elevate if swollen\n'
          '• Take tetanus shot if needed (>5 years)\n\n'
          '⚠️ **Seek immediate care if:**\n'
          '• Deep wounds or significant bleeding\n'
          '• Dirty or contaminated wounds\n'
          '• Signs of infection (increasing pain, redness, pus)\n'
          '• Large or gaping wounds needing stitches\n'
          '• Puncture wounds\n\n'
          '💡 *Professional evaluation prevents complications.*',
      'keywords': ['wound', 'cut', 'injury', 'bleed', 'bleeding', 'scratch'],
      'facilities': ['Emergency Room', 'General Practice', 'Trauma Center'],
    },
    'emergency': {
      'guidance':
          '🚨 **EMERGENCY RESPONSE GUIDE:**\n\n'
          '**For life-threatening situations:**\n'
          '✓ Call emergency services (911/100 in your region)\n'
          '✓ Remain calm and provide clear information\n'
          '✓ Follow dispatcher instructions\n\n'
          '**Life-threatening conditions requiring immediate care:**\n'
          '• Chest pain or pressure\n'
          '• Severe difficulty breathing\n'
          '• Loss of consciousness\n'
          '• Severe bleeding\n'
          '• Signs of stroke (face drooping, arm weakness)\n'
          '• Severe allergic reactions\n'
          '• Severe injuries or trauma\n'
          '• Poisoning or overdose\n\n'
          '**If someone is unresponsive:**\n'
          '1. Call emergency immediately\n'
          '2. Check if breathing\n'
          '3. Put in recovery position (side)\n'
          '4. Perform CPR if trained\n\n'
          '💡 *Time is critical. Always prioritize emergency services over advice.*',
      'keywords': ['emergency', 'urgent', 'critical', '911', 'help'],
      'facilities': ['Emergency Room', 'Trauma Center', 'Critical Care Unit'],
    },
  };

  static final Map<String, String> _usageGuide = {
    'how to use': _buildUsageGuide(),
    'features': _buildFeaturesGuide(),
    'search': _buildSearchGuide(),
    'booking': _buildBookingGuide(),
    'nearby': _buildNearbyGuide(),
    'filters': _buildFilterGuide(),
  };

  static String _buildUsageGuide() {
    return '📱 **How to Use Hospital Finder**\n\n'
        '**Getting Started:**\n'
        '1. Grant location permission for nearby hospitals\n'
        '2. Browse hospitals by Nearby, All, or Search tabs\n'
        '3. Tap any hospital card for detailed information\n'
        '4. Book an appointment using the booking form\n\n'
        '**Main Features:**\n'
        '• 📍 Find nearby hospitals within 50km\n'
        '• 🔍 Search by name, location, or specialty\n'
        '• 📋 Filter by district and state\n'
        '• 📞 View contact information\n'
        '• 💬 Get health assistance via chatbot\n\n'
        '**Tips:**\n'
        '• Enable location for best results\n'
        '• Use search filters for specific needs\n'
        '• Check hospital details before visiting\n'
        '• Keep your location updated\n\n'
        'Need help with a specific feature? Ask away! 😊';
  }

  static String _buildFeaturesGuide() {
    return '✨ **Available Features:**\n\n'
        '🗺️ **Nearby Hospitals Tab**\n'
        'Shows hospitals within 50km of your location\n'
        'Sorted by distance automatically\n\n'
        '📋 **All Hospitals Tab**\n'
        'Complete list of all hospitals in database\n'
        'Can be sorted by distance if location enabled\n\n'
        '🔍 **Search Tab**\n'
        'Advanced search with multiple filters\n'
        'Filter by district, state, or specialty\n'
        'Real-time search as you type\n\n'
        '📍 **Hospital Details**\n'
        'View address, phone, email\n'
        'See specialties and services\n'
        'Check distance to your location\n\n'
        '📅 **Booking Form**\n'
        'Book appointments with hospitals\n'
        'Provide your details and preferred dates\n\n'
        'Any questions about features? 🤔';
  }

  static String _buildSearchGuide() {
    return '🔍 **Search Guide:**\n\n'
        '**How to Search:**\n'
        '1. Go to the Search tab\n'
        '2. Enter hospital name in search bar\n'
        '3. Use filters to narrow results:\n'
        '   • Filter by state\n'
        '   • Filter by district\n'
        '   • Search by specialty\n\n'
        '**Search Tips:**\n'
        '• Be specific with hospital names\n'
        '• Use location filters for faster results\n'
        '• Combine multiple filters for precision\n'
        '• Clear filters to reset search\n\n'
        '**Example Searches:**\n'
        '• "Apollo Hospital"\n'
        '• Search in "Chennai" district\n'
        '• Filter for "Cardiology" specialty\n\n'
        'Can\'t find what you\'re looking for? Try different keywords! 🔎';
  }

  static String _buildBookingGuide() {
    return '📅 **Booking Appointments:**\n\n'
        '**Step-by-Step:**\n'
        '1. Select a hospital from any tab\n'
        '2. Tap the hospital card to see details\n'
        '3. Click "Book Appointment" button\n'
        '4. Fill in the booking form:\n'
        '   • Your name and contact\n'
        '   • Reason for visit\n'
        '   • Preferred date and time\n'
        '5. Submit the form\n\n'
        '**Required Information:**\n'
        '• Patient name\n'
        '• Phone number\n'
        '• Email address\n'
        '• Preferred appointment date\n'
        '• Reason for visit (optional)\n\n'
        '**After Booking:**\n'
        '• You\'ll receive confirmation details\n'
        '• Hospital will contact you\n'
        '• Arrive 15 minutes early\n\n'
        'Having trouble booking? Let me know! 📞';
  }

  static String _buildNearbyGuide() {
    return '📍 **Nearby Hospitals:**\n\n'
        '**About Nearby Tab:**\n'
        'Shows all hospitals within 50km radius\n'
        'Automatically sorted by distance (closest first)\n'
        'Updates based on your current location\n\n'
        '**Requirements:**\n'
        '✓ Location permission must be enabled\n'
        '✓ GPS must be turned on\n'
        '✓ Recent location data\n\n'
        '**How to Use:**\n'
        '1. Enable location permission\n'
        '2. Open the "Nearby" tab\n'
        '3. Hospitals display with distance\n'
        '4. Tap for more details\n'
        '5. Book or contact directly\n\n'
        '**If Not Working:**\n'
        '• Check location is enabled\n'
        '• Go to settings → App permissions\n'
        '• Grant location permission\n'
        '• Refresh the app\n\n'
        'Still having issues? Ask for help! 🆘';
  }

  static String _buildFilterGuide() {
    return '🎯 **Using Filters:**\n\n'
        '**Available Filters:**\n'
        '📍 By Location (State & District)\n'
        '🏥 By Type (Hospital Type)\n'
        '⚕️ By Specialty (Medical Services)\n\n'
        '**How to Filter:**\n'
        '1. Go to Search tab\n'
        '2. Click filter icon at bottom\n'
        '3. Select desired filters\n'
        '4. Results update automatically\n\n'
        '**Filter Combinations:**\n'
        '• Location + Type\n'
        '• Location + Specialty\n'
        '• Type + Specialty\n'
        '• All three together\n\n'
        '**Filter Tips:**\n'
        '• Combine filters for better results\n'
        '• Clear filters to reset\n'
        '• Filters work with search too\n\n'
        'Need help with specific filters? 🤷';
  }

  /// Get response based on user input - handles any question professionally
  static ChatMessage generateResponse(
    String userInput, {
    List<Hospital>? nearbyHospitals,
    Position? userLocation,
  }) {
    final input = userInput.toLowerCase().trim();
    final timestamp = DateTime.now();

    // Check for greeting
    if (_isGreeting(input)) {
      return ChatMessage(
        text: _greetings[DateTime.now().millisecond % _greetings.length],
        isUser: false,
        timestamp: timestamp,
        type: 'text',
      );
    }

    // Check for health-related queries
    for (final entry in _healthKnowledge.entries) {
      final keywords = entry.value['keywords'] as List<String>;
      if (keywords.any((keyword) => input.contains(keyword))) {
        final guidance = entry.value['guidance'] as String;
        final facilities = entry.value['facilities'] as List<String>;

        var response = guidance;

        // Add nearby facility recommendations if available
        if (nearbyHospitals != null && nearbyHospitals.isNotEmpty) {
          response += '\n\n🏥 **Nearby Facilities with these specialties:**\n';
          final relevantHospitals = _filterHospitalsBySpecialty(
            nearbyHospitals,
            facilities,
          );

          if (relevantHospitals.isNotEmpty) {
            for (final hospital in relevantHospitals.take(3)) {
              final distance =
                  userLocation != null
                      ? hospital.distanceFrom(
                        userLocation.latitude,
                        userLocation.longitude,
                      )
                      : 0.0;
              response +=
                  '\n• **${hospital.name}** ${distance > 0 ? '($distance km away)' : ''}';
            }
          } else {
            response += '\nNo nearby hospitals with these specialties.';
          }
        }

        return ChatMessage(
          text: response,
          isUser: false,
          timestamp: timestamp,
          type: 'health_tip',
        );
      }
    }

    // Check for usage guides
    for (final entry in _usageGuide.entries) {
      if (input.contains(entry.key)) {
        return ChatMessage(
          text: entry.value,
          isUser: false,
          timestamp: timestamp,
          type: 'text',
        );
      }
    }

    // Check for facility-related queries
    if (input.contains('nearby') ||
        input.contains('facility') ||
        input.contains('hospital')) {
      if (nearbyHospitals != null && nearbyHospitals.isNotEmpty) {
        var response = '🏥 **Nearby Hospitals (within 50km):**\n\n';
        for (final hospital in nearbyHospitals.take(5)) {
          final distance =
              userLocation != null
                  ? hospital.distanceFrom(
                    userLocation.latitude,
                    userLocation.longitude,
                  )
                  : 0.0;
          response +=
              '• **${hospital.name}** - ${hospital.address}${distance > 0 ? ' [$distance km away]' : ''}\n';
        }
        return ChatMessage(
          text: response,
          isUser: false,
          timestamp: timestamp,
          type: 'facility_info',
        );
      }
    }

    // Check for general knowledge questions
    final generalResponse = _getGeneralKnowledgeResponse(input);
    if (generalResponse.isNotEmpty) {
      return ChatMessage(
        text: generalResponse,
        isUser: false,
        timestamp: timestamp,
        type: 'text',
      );
    }

    // Default response for any other question
    return ChatMessage(
      text: _getDefaultResponse(input),
      isUser: false,
      timestamp: timestamp,
      type: 'text',
    );
  }

  /// Handle general knowledge questions professionally
  static String _getGeneralKnowledgeResponse(String input) {
    // Medical/Health general questions
    if (_matchesKeywords(input, [
      'health',
      'wellness',
      'fitness',
      'exercise',
      'diet',
      'nutrition',
      'sleep',
      'mental health',
      'stress',
      'anxiety',
      'depression',
      'meditation',
      'yoga',
    ])) {
      return _handleHealthWellnessQuestion(input);
    }

    // Hospital/Healthcare services questions
    if (_matchesKeywords(input, [
      'hospital',
      'doctor',
      'clinic',
      'treatment',
      'medication',
      'surgery',
      'appointment',
      'specialist',
      'consultation',
      'diagnosis',
      'insurance',
    ])) {
      return _handleHealthcareServiceQuestion(input);
    }

    // Prevention and hygiene questions
    if (_matchesKeywords(input, [
      'prevention',
      'hygiene',
      'cleaning',
      'disinfect',
      'sanitize',
      'infection',
      'disease',
      'vaccine',
      'immunity',
      'immune',
    ])) {
      return _handlePreventionQuestion(input);
    }

    // Lifestyle and habit questions
    if (_matchesKeywords(input, [
      'smoking',
      'alcohol',
      'drinking',
      'substance',
      'addiction',
      'quit',
      'stop',
      'healthy habit',
      'lifestyle',
    ])) {
      return _handleLifestyleQuestion(input);
    }

    // Emergency and first aid questions
    if (_matchesKeywords(input, [
      'first aid',
      'CPR',
      'rescue',
      'emergency care',
      'trauma',
      'injury',
      'accident',
    ])) {
      return _handleFirstAidQuestion(input);
    }

    // Age-specific health questions
    if (_matchesKeywords(input, [
      'pregnancy',
      'pregnant',
      'baby',
      'infant',
      'child',
      'children',
      'senior',
      'elderly',
      'age',
    ])) {
      return _handleAgeSpecificQuestion(input);
    }

    // Medication and drug questions
    if (_matchesKeywords(input, [
      'medication',
      'medicine',
      'drug',
      'tablet',
      'capsule',
      'injection',
      'side effect',
      'allergy',
      'interaction',
    ])) {
      return _handleMedicationQuestion(input);
    }

    // Sexual and reproductive health
    if (_matchesKeywords(input, [
      'sexual',
      'contraception',
      'birth control',
      'std',
      'sti',
      'reproductive',
      'family planning',
    ])) {
      return _handleReproductiveHealthQuestion(input);
    }

    return '';
  }

  /// Utility to match keywords in input
  static bool _matchesKeywords(String input, List<String> keywords) {
    return keywords.any((keyword) => input.contains(keyword.toLowerCase()));
  }

  static String _handleHealthWellnessQuestion(String input) {
    if (_matchesKeywords(input, ['exercise', 'fitness', 'workout', 'gym'])) {
      return '💪 **Exercise & Fitness Guidance**\n\n'
          '**Benefits of Regular Exercise:**\n'
          '✓ Improves cardiovascular health\n'
          '✓ Strengthens bones and muscles\n'
          '✓ Enhances mental wellbeing\n'
          '✓ Helps maintain healthy weight\n'
          '✓ Reduces risk of chronic diseases\n\n'
          '**Recommended Activity:**\n'
          '• 150 minutes moderate-intensity aerobic activity per week\n'
          '• 2+ days of strength training per week\n'
          '• Flexibility exercises 2-3 times per week\n\n'
          '**Starting an Exercise Routine:**\n'
          '1. Consult healthcare provider before starting (especially if sedentary)\n'
          '2. Start gradually - 10-15 minutes daily\n'
          '3. Choose activities you enjoy\n'
          '4. Stay consistent and progressive\n'
          '5. Warm up and cool down properly\n'
          '6. Stay hydrated during exercise\n\n'
          '**Safety Tips:**\n'
          '• Listen to your body\n'
          '• Avoid overexertion initially\n'
          '• Use proper form and technique\n'
          '• Rest days are important\n'
          '• Stop if experiencing chest pain or severe discomfort\n\n'
          '💡 *A fitness professional can create personalized programs.*';
    }

    if (_matchesKeywords(input, [
      'diet',
      'nutrition',
      'food',
      'eat',
      'eating',
      'balanced diet',
    ])) {
      return '🥗 **Nutrition & Diet Guidance**\n\n'
          '**Components of Healthy Diet:**\n'
          '🥕 **Vegetables & Fruits** - 5+ portions daily\n'
          '🌾 **Whole Grains** - Brown rice, wheat, oats\n'
          '🍗 **Protein** - Lean meat, fish, legumes, eggs\n'
          '🥛 **Dairy** - Milk, yogurt, cheese (or alternatives)\n'
          '🥜 **Healthy Fats** - Olive oil, nuts, avocados\n\n'
          '**Hydration:**\n'
          '• Drink 8-10 glasses of water daily\n'
          '• More in hot weather or during exercise\n'
          '• Limit sugary beverages\n\n'
          '**Healthy Eating Habits:**\n'
          '• Eat slowly and chew thoroughly\n'
          '• Don\'t skip meals, especially breakfast\n'
          '• Control portion sizes\n'
          '• Limit processed foods and added sugar\n'
          '• Reduce salt intake\n'
          '• Balance meals with all nutrients\n\n'
          '**Foods to Limit:**\n'
          '✗ Sugary drinks and snacks\n'
          '✗ Processed foods\n'
          '✗ High-sodium foods\n'
          '✗ Excessive saturated fats\n\n'
          '💡 *Consult a dietitian for personalized nutrition plans.*';
    }

    if (_matchesKeywords(input, [
      'sleep',
      'insomnia',
      'rest',
      'tired',
      'fatigue',
    ])) {
      return '😴 **Sleep & Rest Guidance**\n\n'
          '**Importance of Sleep:**\n'
          '• Essential for physical recovery\n'
          '• Important for mental health\n'
          '• Strengthens immune system\n'
          '• Improves concentration and memory\n'
          '• Supports healthy metabolism\n\n'
          '**Recommended Sleep Duration:**\n'
          '• Adults: 7-9 hours per night\n'
          '• Teenagers: 8-10 hours per night\n'
          '• Children: 9-12 hours per night\n'
          '• Toddlers: 11-14 hours per night\n\n'
          '**Tips for Better Sleep:**\n'
          '✓ Maintain consistent sleep schedule\n'
          '✓ Keep bedroom cool, dark, and quiet\n'
          '✓ Avoid screens 1 hour before bed\n'
          '✓ Limit caffeine after 2 PM\n'
          '✓ Avoid heavy meals before sleep\n'
          '✓ Exercise regularly (not before bed)\n'
          '✓ Practice relaxation techniques\n'
          '✓ Expose to natural light during day\n\n'
          '**If Sleep Issues Persist:**\n'
          '• Consult a sleep specialist\n'
          '• Consider cognitive behavioral therapy\n'
          '• Avoid self-medication\n\n'
          '💡 *Professional help ensures proper diagnosis.*';
    }

    if (_matchesKeywords(input, [
      'stress',
      'anxiety',
      'depression',
      'mental',
    ])) {
      return '🧠 **Mental Health & Stress Management**\n\n'
          '**Understanding Stress & Anxiety:**\n'
          'These are normal responses to challenges but need management when excessive.\n\n'
          '**Physical Symptoms:**\n'
          '• Headaches or muscle tension\n'
          '• Sleep disturbances\n'
          '• Fatigue or loss of energy\n'
          '• Changes in appetite\n'
          '• Difficulty concentrating\n\n'
          '**Stress Management Techniques:**\n'
          '🧘 **Meditation & Mindfulness**\n'
          '• Start with 5-10 minutes daily\n'
          '• Focus on breathing\n'
          '• Reduces anxiety and improves focus\n\n'
          '🏃 **Physical Activity**\n'
          '• Exercise releases endorphins\n'
          '• 30 minutes daily is beneficial\n\n'
          '📝 **Journaling**\n'
          '• Express thoughts and feelings\n'
          '• Helps process emotions\n\n'
          '🤝 **Social Connection**\n'
          '• Talk to friends and family\n'
          '• Join support groups\n\n'
          '**When to Seek Professional Help:**\n'
          '⚠️ Persistent sadness lasting weeks\n'
          '⚠️ Loss of interest in activities\n'
          '⚠️ Thoughts of self-harm\n'
          '⚠️ Difficulty functioning daily\n\n'
          '💡 *Mental health professionals provide evidence-based treatment.*';
    }

    return '✨ **Health & Wellness Guidance**\n\n'
        'To live a healthy lifestyle:\n\n'
        '1. **Regular Exercise** - At least 150 min/week of moderate activity\n'
        '2. **Balanced Nutrition** - Include all food groups\n'
        '3. **Quality Sleep** - 7-9 hours daily\n'
        '4. **Stress Management** - Meditation, exercise, hobbies\n'
        '5. **Social Connections** - Maintain relationships\n'
        '6. **Regular Check-ups** - Preventive healthcare\n'
        '7. **Healthy Habits** - Avoid smoking and excess alcohol\n'
        '8. **Hydration** - Drink adequate water\n\n'
        '💡 *Consult healthcare providers for personalized guidance.*';
  }

  static String _handleHealthcareServiceQuestion(String input) {
    return '🏥 **Healthcare Services Information**\n\n'
        '**Types of Healthcare Providers:**\n'
        '• **General Practitioner (GP)** - Primary care, routine check-ups\n'
        '• **Specialist** - Focused expertise (cardiology, dermatology, etc.)\n'
        '• **Nurse Practitioner** - Advanced nursing care\n'
        '• **Dentist** - Oral health\n'
        '• **Therapist** - Mental health support\n\n'
        '**When to See a Doctor:**\n'
        '• Persistent symptoms (>2 weeks)\n'
        '• Worsening conditions\n'
        '• Medication concerns\n'
        '• Preventive check-ups\n'
        '• Emergency situations\n\n'
        '**Preparing for Appointments:**\n'
        '✓ List symptoms and their duration\n'
        '✓ Bring medications and medical history\n'
        '✓ Write down questions\n'
        '✓ Bring insurance information\n'
        '✓ Arrive early\n\n'
        '**Using Hospital Finder:**\n'
        '• Search hospitals by location\n'
        '• Filter by specialty\n'
        '• Book appointments easily\n'
        '• Find nearby urgent care\n\n'
        '💡 *Our app helps you find the right healthcare quickly.*';
  }

  static String _handlePreventionQuestion(String input) {
    return '🛡️ **Disease Prevention & Health Protection**\n\n'
        '**Key Prevention Strategies:**\n\n'
        '✓ **Vaccinations**\n'
        '• Follow recommended vaccine schedules\n'
        '• Protects against serious diseases\n'
        '• Builds community immunity\n\n'
        '✓ **Hand Hygiene**\n'
        '• Wash hands for 20 seconds\n'
        '• Before eating and after restroom\n'
        '• After coughing/sneezing\n'
        '• Prevents pathogen transmission\n\n'
        '✓ **Respiratory Etiquette**\n'
        '• Cover mouth when coughing/sneezing\n'
        '• Use tissue or elbow\n'
        '• Avoid close contact when ill\n\n'
        '✓ **Environmental Hygiene**\n'
        '• Regular cleaning of surfaces\n'
        '• Proper food handling\n'
        '• Safe drinking water\n'
        '• Adequate sanitation\n\n'
        '✓ **Lifestyle Prevention**\n'
        '• Avoid smoking and excess alcohol\n'
        '• Maintain healthy weight\n'
        '• Regular exercise\n'
        '• Healthy diet\n'
        '• Manage stress\n\n'
        '✓ **Regular Check-ups**\n'
        '• Preventive health screenings\n'
        '• Early disease detection\n'
        '• Monitoring chronic conditions\n\n'
        '💡 *Prevention is better and cheaper than treatment.*';
  }

  static String _handleLifestyleQuestion(String input) {
    return '🚭 **Lifestyle Changes & Health Habits**\n\n'
        '**Quitting Harmful Habits:**\n\n'
        '🚭 **Smoking Cessation**\n'
        '• Benefits start immediately:\n'
        '  - 20 min: Heart rate normalizes\n'
        '  - 12 hours: Carbon monoxide cleared\n'
        '  - 1 week: Nicotine levels drop\n'
        '  - 1 month: Lung function improves\n'
        '• Seek professional support (counseling, medication)\n'
        '• Use nicotine replacement therapy if needed\n\n'
        '🍺 **Reducing Alcohol**\n'
        '• Safe limits: Men 2, Women 1 drink/day\n'
        '• Effects improve within weeks\n'
        '• Support groups available\n'
        '• Medical help for addiction\n\n'
        '**Building Healthy Habits:**\n'
        '1. Start small - one change at a time\n'
        '2. Set specific, achievable goals\n'
        '3. Track progress\n'
        '4. Get support from friends/family\n'
        '5. Celebrate small victories\n'
        '6. Don\'t give up after setbacks\n\n'
        '**Professional Support:**\n'
        '• Behavioral counseling\n'
        '• Support groups\n'
        '• Addiction specialists\n'
        '• Medical interventions if needed\n\n'
        '💡 *Professional guidance increases success rates significantly.*';
  }

  static String _handleFirstAidQuestion(String input) {
    return '🚨 **First Aid & Emergency Response**\n\n'
        '**Basic First Aid Principles:**\n'
        '1. **Ensure Safety** - Check for dangers\n'
        '2. **Call Emergency** - Dial 911/100\n'
        '3. **Assess Victim** - Check responsiveness\n'
        '4. **Provide Care** - Help while waiting for ambulance\n\n'
        '**Common First Aid Situations:**\n\n'
        '🩹 **Minor Cuts & Scrapes**\n'
        '• Apply pressure to stop bleeding\n'
        '• Clean with running water\n'
        '• Apply antiseptic\n'
        '• Cover with bandage\n\n'
        '❄️ **Burns**\n'
        '• Cool with water for 10-20 minutes\n'
        '• Remove tight jewelry\n'
        '• Cover with clean cloth\n'
        '• Seek medical care for severe burns\n\n'
        '🦴 **Sprains & Fractures**\n'
        '• Rest, immobilize, elevate\n'
        '• Apply ice for 15-20 minutes\n'
        '• Seek medical evaluation\n\n'
        '🤐 **Choking**\n'
        '• Back blows and abdominal thrusts\n'
        '• Call emergency if not cleared\n'
        '• CPR training strongly recommended\n\n'
        '⚠️ **Life-Threatening Emergencies:**\n'
        '• Chest pain or difficulty breathing\n'
        '• Unconsciousness\n'
        '• Severe bleeding\n'
        '• Signs of stroke\n'
        '→ **Call emergency immediately (911/100)**\n\n'
        '💡 *Take a certified first aid course for hands-on training.*';
  }

  static String _handleAgeSpecificQuestion(String input) {
    if (_matchesKeywords(input, ['pregnancy', 'pregnant', 'pregnancy'])) {
      return '🤰 **Pregnancy & Prenatal Care**\n\n'
          '**Regular Prenatal Check-ups:**\n'
          '• First trimester (0-12 weeks): Monthly visits\n'
          '• Second trimester (12-28 weeks): Monthly visits\n'
          '• Third trimester (28+ weeks): Bi-weekly then weekly\n'
          '• Screening tests and ultrasounds\n\n'
          '**Important During Pregnancy:**\n'
          '✓ Prenatal vitamins (folic acid, iron)\n'
          '✓ Healthy diet with adequate nutrition\n'
          '✓ Regular moderate exercise\n'
          '✓ Adequate rest and sleep\n'
          '✓ Avoid alcohol, smoking, and drugs\n'
          '✓ Stay hydrated\n\n'
          '**Warning Signs - Seek Help If:**\n'
          '⚠️ Vaginal bleeding or spotting\n'
          '⚠️ Severe abdominal pain\n'
          '⚠️ Persistent vomiting\n'
          '⚠️ Dizziness or fainting\n'
          '⚠️ Signs of infection\n'
          '⚠️ Reduced fetal movement\n\n'
          '**Preparation for Delivery:**\n'
          '• Birth plan discussions\n'
          '• Prenatal classes\n'
          '• Hospital tour\n'
          '• Support person arrangement\n\n'
          '💡 *Obstetric specialists provide comprehensive pregnancy care.*';
    }

    if (_matchesKeywords(input, ['baby', 'infant', 'newborn', 'baby care'])) {
      return '👶 **Infant & Baby Care**\n\n'
          '**Newborn Essentials:**\n'
          '• Feeding (breast or formula)\n'
          '• Diaper care and hygiene\n'
          '• Sleep schedule and safety\n'
          '• Temperature regulation\n'
          '• Immunizations\n\n'
          '**Warning Signs in Babies:**\n'
          '⚠️ High fever (>38°C/100.4°F)\n'
          '⚠️ Difficulty breathing\n'
          '⚠️ Unusual crying or lethargy\n'
          '⚠️ Poor feeding or weight loss\n'
          '⚠️ Skin rashes or yellowing\n'
          '⚠️ Seizures or convulsions\n\n'
          '**Vaccination Schedule:**\n'
          '• Follow recommended pediatric schedule\n'
          '• Regular check-ups at pediatrician\n'
          '• Developmental screening\n'
          '• Growth monitoring\n\n'
          '**Safety:**\n'
          '• Back sleeping position\n'
          '• Firm sleep surface\n'
          '• No pillows or loose items\n'
          '• Room sharing without bed-sharing\n'
          '• Avoid overheating\n\n'
          '💡 *Pediatricians specialize in infant care and development.*';
    }

    if (_matchesKeywords(input, ['child', 'children', 'kid', 'kids'])) {
      return '👧 **Children\'s Health & Development**\n\n'
          '**Developmental Milestones:**\n'
          '• Monitor physical, cognitive, and social development\n'
          '• Regular pediatric check-ups\n'
          '• Developmental screening\n'
          '• Address delays early\n\n'
          '**Nutrition for Children:**\n'
          '• Balanced diet with all nutrients\n'
          '• Age-appropriate portion sizes\n'
          '• Regular meal times\n'
          '• Limit sugary foods and drinks\n'
          '• Ensure adequate calcium for bones\n\n'
          '**Physical Activity:**\n'
          '• Minimum 60 minutes daily\n'
          '• Mix of aerobic and strength activities\n'
          '• Screen time limits (1-2 hours quality content)\n'
          '• Outdoor play\n\n'
          '**Common Childhood Conditions:**\n'
          '• Minor infections (cold, flu)\n'
          '• Ear infections\n'
          '• Gastroenteritis\n'
          '• Asthma\n'
          '• Allergies\n\n'
          '**Safety:**\n'
          '• Age-appropriate supervision\n'
          '• Vaccination maintenance\n'
          '• Accident prevention\n'
          '• Dental care\n\n'
          '💡 *Regular pediatric care ensures healthy development.*';
    }

    return '👴 **Senior Health & Aging**\n\n'
        '**Common Health Issues in Seniors:**\n'
        '• Hypertension and heart disease\n'
        '• Diabetes\n'
        '• Arthritis and joint problems\n'
        '• Vision and hearing changes\n'
        '• Cognitive changes\n'
        '• Medication management\n\n'
        '**Regular Health Monitoring:**\n'
        '• Annual comprehensive health check-ups\n'
        '• Blood pressure monitoring\n'
        '• Cholesterol screening\n'
        '• Cancer screenings (age-appropriate)\n'
        '• Bone density screening\n'
        '• Vision and hearing tests\n\n'
        '**Healthy Aging:**\n'
        '✓ Regular physical activity (adapted for ability)\n'
        '✓ Balanced, nutritious diet\n'
        '✓ Social engagement\n'
        '✓ Mental stimulation\n'
        '✓ Adequate sleep\n'
        '✓ Medication adherence\n\n'
        '**Fall Prevention:**\n'
        '• Remove home hazards\n'
        '• Install grab bars\n'
        '• Ensure adequate lighting\n'
        '• Wear appropriate footwear\n'
        '• Regular vision checks\n'
        '• Exercise for balance and strength\n\n'
        '💡 *Geriatric specialists provide specialized senior care.*';
  }

  static String _handleMedicationQuestion(String input) {
    return '💊 **Medication & Drug Information**\n\n'
        '**About Medications:**\n'
        '• Take exactly as prescribed\n'
        '• Complete full course even if feeling better\n'
        '• Store properly (cool, dry place)\n'
        '• Check expiry dates\n'
        '• Keep in original containers\n\n'
        '**Common Side Effects:**\n'
        '• Nausea, dizziness, headache\n'
        '• Rashes or skin reactions\n'
        '• Sleep disturbances\n'
        '• Digestive issues\n'
        '• Most side effects temporary and mild\n\n'
        '**When to Report Concerns:**\n'
        '⚠️ Severe allergic reactions\n'
        '⚠️ Chest pain or difficulty breathing\n'
        '⚠️ Severe skin reactions\n'
        '⚠️ Unusual bleeding or bruising\n'
        '⚠️ Severe digestive issues\n'
        '⚠️ Behavioral changes\n\n'
        '**Drug Interactions:**\n'
        '• Inform doctor about all medications\n'
        '• Include over-the-counter drugs\n'
        '• Mention supplements and herbal products\n'
        '• Avoid self-medication\n\n'
        '**Managing Medications:**\n'
        '✓ Use pill organizer for multiple medications\n'
        '✓ Set phone reminders\n'
        '✓ Keep medication log\n'
        '✓ Regular pharmacy check-ups\n'
        '✓ Don\'t share medications\n\n'
        '💡 *Always consult pharmacist or doctor about medications.*';
  }

  static String _handleReproductiveHealthQuestion(String input) {
    return '🏥 **Sexual & Reproductive Health**\n\n'
        '**Safe Practices:**\n'
        '✓ Use contraception consistently\n'
        '✓ Get regular STI screening\n'
        '✓ Communicate with partner\n'
        '✓ Know your sexual health status\n'
        '✓ Vaccinations (HPV, Hepatitis B)\n\n'
        '**Contraception Options:**\n'
        '• Barrier methods (condoms, diaphragm)\n'
        '• Hormonal (pill, patch, shot, implant)\n'
        '• Long-acting (IUD, implant)\n'
        '• Permanent (sterilization)\n'
        '• Natural family planning\n\n'
        '**STI Prevention & Testing:**\n'
        '• Regular screening if sexually active\n'
        '• Barrier method use\n'
        '• Partner notification if positive\n'
        '• Proper treatment completion\n'
        '• Safe practices during treatment\n\n'
        '**Women\'s Reproductive Health:**\n'
        '• Annual gynecological exams\n'
        '• Pap smears (cervical cancer screening)\n'
        '• Breast health awareness\n'
        '• Menstrual health monitoring\n'
        '• Menopausal transition support\n\n'
        '**Men\'s Sexual Health:**\n'
        '• Prostate health screening\n'
        '• Testicular self-exams\n'
        '• Sexual dysfunction evaluation\n'
        '• Preventive health check-ups\n\n'
        '💡 *Reproductive health specialists provide comprehensive care.*';
  }

  static bool _isGreeting(String input) {
    final greetingKeywords = [
      'hello',
      'hi',
      'hey',
      'greetings',
      'start',
      'help',
      'assist',
    ];
    return greetingKeywords.any((keyword) => input.contains(keyword));
  }

  static List<Hospital> _filterHospitalsBySpecialty(
    List<Hospital> hospitals,
    List<String> specialties,
  ) {
    return hospitals.where((hospital) {
      final hospitalServices = hospital.specialties;
      return specialties.any(
        (specialty) => hospitalServices.contains(specialty.toLowerCase()),
      );
    }).toList();
  }

  static String _getDefaultResponse(String userInput) {
    return '✅ **Thank you for your question!**\n\n'
        'I\'m a comprehensive Health Assistant designed to help with:\n\n'
        '**💊 Medical & Health Topics**\n'
        '• Symptoms and conditions (fever, cough, pain, etc.)\n'
        '• Health and wellness guidance\n'
        '• Medication and drug information\n'
        '• Disease prevention and hygiene\n'
        '• First-aid and emergency response\n\n'
        '**🏥 Healthcare Services**\n'
        '• Finding nearby hospitals\n'
        '• Healthcare provider information\n'
        '• Appointment booking help\n'
        '• Specialist recommendations\n\n'
        '**👨‍👩‍👧‍👦 Age-Specific Health**\n'
        '• Pregnancy and prenatal care\n'
        '• Baby and infant care\n'
        '• Children\'s health\n'
        '• Senior health and aging\n\n'
        '**🧠 Lifestyle & Wellness**\n'
        '• Exercise and fitness\n'
        '• Nutrition and diet\n'
        '• Sleep and rest\n'
        '• Stress and mental health\n'
        '• Breaking unhealthy habits\n\n'
        '**📱 App Features**\n'
        '• How to use Hospital Finder\n'
        '• Searching and filtering\n'
        '• Booking appointments\n\n'
        '**💡 Pro Tips:**\n'
        '• Be specific with your question for better answers\n'
        '• Mention symptoms in detail\n'
        '• Ask about nearby facilities\n'
        '• Ask for professional guidance recommendations\n\n'
        '⚠️ **Important:** This chatbot provides general, professional health information based on standard medical guidelines. '
        'It is NOT a substitute for medical diagnosis or treatment by qualified healthcare professionals. '
        'For life-threatening emergencies, immediately contact emergency services (911/100). '
        'Always consult healthcare providers for personalized medical advice.\n\n'
        '**What would you like to know?** 🤔';
  }

  /// Get suggested questions based on context
  static List<String> getSuggestedQuestions() {
    return [
      'How do I use this app?',
      'Show nearby hospitals',
      'I have a fever',
      'Tell me about exercise',
      'Sleep problems help',
      'Mental health support',
      'Healthy diet tips',
      'Emergency guidance',
      'Stress management',
      'Medication questions',
    ];
  }
}
