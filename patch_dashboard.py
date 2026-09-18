import re

dashboard_page_path = r'C:\kuliah\gawean\child-games\rei-dashboard\app\results\page.tsx'

with open(dashboard_page_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update user_answers query to add order("answered_at", { ascending: true }) before range
old_query = '.in("question_id", questionIds)\n          .range(from, from + chunkPageSize - 1)'
new_query = '.in("question_id", questionIds)\n          .order("answered_at", { ascending: true })\n          .range(from, from + chunkPageSize - 1)'

if old_query in content:
    content = content.replace(old_query, new_query)
    print("1. Added .order('answered_at', { ascending: true }) to user_answers query.")
else:
    print("1. Query string match failed or already updated.")

# 2. Fix answer mapping logic so newer answers are processed and invalid option fallback is handled cleanly
old_mapping = '''        userResult.answers[question?.id] = {
          question_text: question?.question_text || "",
          selected_option: option?.option_text || "No answer",
          score: option?.score_option || 0
        }'''

new_mapping = '''        if (question?.id) {
          userResult.answers[question.id] = {
            question_text: question.question_text || "",
            selected_option: option?.option_text || (answer.selected_option_id ? "Terisi (Option ID: " + answer.selected_option_id.substring(0,6) + ")" : "No answer"),
            score: option?.score_option || 0
          }
        }'''

if old_mapping in content:
    content = content.replace(old_mapping, new_mapping)
    print("2. Improved answer mapping logic and option text fallback.")
else:
    print("2. Mapping string match failed or already updated.")

with open(dashboard_page_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Dashboard page.tsx patch complete!")
