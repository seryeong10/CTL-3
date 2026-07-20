package com.baeumpay.backend.attendance.controller;

import com.baeumpay.backend.attendance.dto.AttendanceResponse;
import com.baeumpay.backend.attendance.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/attendance")
public class AttendanceController {

    private final AttendanceService attendanceService;

    @PostMapping("/{userId}")
    public AttendanceResponse checkAttendance(
            @PathVariable Long userId
    ) {

        return attendanceService
                .checkAttendance(userId);
    }

    @GetMapping("/{userId}")
    public AttendanceResponse getAttendanceStatus(
            @PathVariable Long userId
    ) {

        return attendanceService
                .getAttendanceStatus(userId);
    }
}