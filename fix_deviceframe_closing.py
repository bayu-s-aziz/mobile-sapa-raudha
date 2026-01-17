import re

files_to_fix = [
    "lib/app/modules/admin_announcement_form/admin_announcement_form_view.dart",
    "lib/app/modules/admin_announcement_management/admin_announcement_management_view.dart",
    "lib/app/modules/admin_attendance_management/admin_attendance_management_view.dart",
    "lib/app/modules/admin_password_reset/admin_password_reset_view.dart",
    "lib/app/modules/admin_student_management/admin_student_management_view.dart",
    "lib/app/modules/admin_teacher_form/admin_teacher_form_view.dart",
    "lib/app/modules/admin_user_management/admin_user_management_view.dart",
    "lib/app/modules/attendance_history/attendance_history_view.dart",
    "lib/app/modules/change_password/change_password_view.dart",
    "lib/app/modules/leave_list/leave_list_view.dart",
]

for filepath in files_to_fix:
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    # Find the closing of build method - look for pattern:
    # "    );\n  }\n"
    # and replace with:
    # "    );\n      );\n    );\n  }\n"
    
    result = []
    i = 0
    while i < len(lines):
        if i < len(lines) - 1:
            # Check if current line is ");" with 4 spaces and next is "  }"
            if lines[i] == '    );\n' and lines[i+1] == '  }\n':
                # Check if this is in build method by looking back
                # to see if we have DeviceFrame
                has_deviceframe = False
                for j in range(max(0, i-50), i):
                    if 'DeviceFrame(' in lines[j]:
                        has_deviceframe = True
                        break
                
                if has_deviceframe:
                    result.append(lines[i])  # Keep the ");"
                    result.append('      );\n')  # Add DeviceFrame closing
                    result.append('    );\n')   # Add another closing
                    i += 1
                    continue
        
        result.append(lines[i])
        i += 1
    
    with open(filepath, 'w') as f:
        f.writelines(result)
    
    print(f"Fixed: {filepath}")

print("\nAll files fixed!")
