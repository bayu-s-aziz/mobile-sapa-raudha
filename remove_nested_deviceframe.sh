#!/bin/bash

# List of child views that should NOT have DeviceFrame (called from HomeView)
files=(
    "lib/app/modules/announcement_list/announcement_list_view.dart"
    "lib/app/modules/student_list/student_list_view.dart"
    "lib/app/modules/leave_list/leave_list_view.dart"
    "lib/app/modules/profile/profile_view.dart"
    "lib/app/modules/confirm_leave/confirm_leave_view.dart"
    "lib/app/modules/student_profile/student_profile_view.dart"
    "lib/app/modules/attendance_history/attendance_history_view.dart"
    "lib/app/modules/announcement_detail/announcement_detail_view.dart"
    "lib/app/modules/request_leave/request_leave_view.dart"
    "lib/app/modules/edit_profile/edit_profile_view.dart"
    "lib/app/modules/change_password/change_password_view.dart"
    "lib/app/modules/student_detail/student_detail_view.dart"
    "lib/app/modules/scan_presence/scan_presence_view.dart"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        # Remove import
        sed -i "/import 'package:device_frame\/device_frame.dart';/d" "$file"
        # Remove DeviceFrame wrapper - replace pattern
        sed -i 's/return DeviceFrame(/return /' "$file"
        sed -i '/device: Devices\.android\.samsungGalaxyA50,/d' "$file"
        sed -i 's/screen: Scaffold(/Scaffold(/' "$file"
        # Remove extra closing parentheses (need to be careful with this)
    fi
done

echo "Done! Now fixing closing brackets..."
