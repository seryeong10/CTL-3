package com.baeumpay.backend.attendance.dto;

import java.time.LocalDate;

public record AttendanceResponse(
        Long attendanceId,
        Long userId,
        LocalDate attendanceDate,
        boolean todayChecked,
        long consecutiveDays,
        long totalDays,
        String message
) {
}