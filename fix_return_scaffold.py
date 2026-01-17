import re

files = [
    "lib/app/modules/announcement_list/announcement_list_view.dart",
    "lib/app/modules/student_list/student_list_view.dart",
    "lib/app/modules/leave_list/leave_list_view.dart",
    "lib/app/modules/profile/profile_view.dart",
    "lib/app/modules/confirm_leave/confirm_leave_view.dart",
    "lib/app/modules/student_profile/student_profile_view.dart",
    "lib/app/modules/attendance_history/attendance_history_view.dart",
    "lib/app/modules/announcement_detail/announcement_detail_view.dart",
    "lib/app/modules/request_leave/request_leave_view.dart",
    "lib/app/modules/edit_profile/edit_profile_view.dart",
    "lib/app/modules/change_password/change_password_view.dart",
    "lib/app/modules/student_detail/student_detail_view.dart",
    "lib/app/modules/scan_presence/scan_presence_view.dart",
]

for filepath in files:
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Fix: return \n      Scaffold( -> return Scaffold(
        content = re.sub(r'return\s+\n\s+Scaffold\(', 'return Scaffold(', content)
        
        # Remove extra closing parentheses at the end of build method
        # Look for pattern: ),\n      ),\n    );\n  }
        # Replace with: ),\n    );\n  }
        content = re.sub(r'\),\n\s+\),\n\s+\);', '),\n    );', content)
        
        with open(filepath, 'w') as f:
            f.write(content)
        
        print(f"Fixed: {filepath}")
    except Exception as e:
        print(f"Error fixing {filepath}: {e}")

print("\nAll files fixed!")
