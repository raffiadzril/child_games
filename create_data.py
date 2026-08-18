import json
import os

with open('adult_questions.json', encoding='utf-8') as f:
    items = json.load(f)

dart_code = '''import '../models/question_model.dart';
import '../models/option_model.dart';

class AdultQuestionItem {
  final int number;
  final String variable; // Respect, Equity, Inclusion
  final String indicator;
  final String questionText;
  final bool isPositive; // true for '+', false for '-'

  const AdultQuestionItem({
    required this.number,
    required this.variable,
    required this.indicator,
    required this.questionText,
    required this.isPositive,
  });
}

class AdultQuestionsData {
  static const List<AdultQuestionItem> questions = [
'''

for item in items:
    q_num = item['no']
    var_name = item['variable'].replace("'", "\\'")
    ind_name = item['indicator'].replace("'", "\\'")
    q_text = item['question_text'].replace("'", "\\'")
    is_pos = 'true' if item['point_type'] == '+' else 'false'
    
    dart_code += f'''    AdultQuestionItem(
      number: {q_num},
      variable: '{var_name}',
      indicator: '{ind_name}',
      questionText: '{q_text}',
      isPositive: {is_pos},
    ),
'''

dart_code += '''];

  static const List<Map<String, dynamic>> likertOptions = [
    {
      'label': 'A',
      'text': 'Sangat tidak seperti saya',
      'pos_score': 1,
      'neg_score': 5,
    },
    {
      'label': 'B',
      'text': 'Tidak seperti saya',
      'pos_score': 2,
      'neg_score': 4,
    },
    {
      'label': 'C',
      'text': 'Kadang seperti saya',
      'pos_score': 3,
      'neg_score': 3,
    },
    {
      'label': 'D',
      'text': 'Seperti Saya',
      'pos_score': 4,
      'neg_score': 2,
    },
    {
      'label': 'E',
      'text': 'Sangat seperti saya',
      'pos_score': 5,
      'neg_score': 1,
    },
  ];
}
'''

os.makedirs('lib/data/data_sources', exist_ok=True)
with open('lib/data/data_sources/adult_questions_data.dart', 'w', encoding='utf-8') as f:
    f.write(dart_code)

print('adult_questions_data.dart created successfully!')
