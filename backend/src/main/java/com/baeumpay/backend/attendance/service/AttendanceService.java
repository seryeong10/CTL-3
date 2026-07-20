package com.baeumpay.backend.attendance.service;

import com.baeumpay.backend.attendance.dto.AttendanceResponse;
import com.baeumpay.backend.attendance.entity.Attendance;
import com.baeumpay.backend.attendance.repository.AttendanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AttendanceService {

    private final AttendanceRepository attendanceRepository;

    @Transactional
    public AttendanceResponse checkAttendance(
            Long userId
    ) {

        LocalDate today = LocalDate.now();

        Optional<Attendance> todayAttendance =
                attendanceRepository
                        .findByUserIdAndAttendanceDate(
                                userId,
                                today
                        );

        if (todayAttendance.isPresent()) {

            Attendance attendance =
                    todayAttendance.get();

            return new AttendanceResponse(
                    attendance.getAttendanceId(),
                    userId,
                    today,
                    true,
                    calculateConsecutiveDays(userId),
                    attendanceRepository.countByUserId(userId),
                    "오늘은 이미 출석했습니다."
            );
        }

        Attendance attendance = new Attendance(
                userId,
                today
        );

        Attendance savedAttendance =
                attendanceRepository.save(attendance);

        return new AttendanceResponse(
                savedAttendance.getAttendanceId(),
                userId,
                today,
                true,
                calculateConsecutiveDays(userId),
                attendanceRepository.countByUserId(userId),
                "출석 체크가 완료되었습니다."
        );
    }

    public AttendanceResponse getAttendanceStatus(
            Long userId
    ) {

        LocalDate today = LocalDate.now();

        Optional<Attendance> todayAttendance =
                attendanceRepository
                        .findByUserIdAndAttendanceDate(
                                userId,
                                today
                        );

        boolean todayChecked =
                todayAttendance.isPresent();

        Long attendanceId =
                todayAttendance
                        .map(Attendance::getAttendanceId)
                        .orElse(null);

        return new AttendanceResponse(
                attendanceId,
                userId,
                today,
                todayChecked,
                calculateConsecutiveDays(userId),
                attendanceRepository.countByUserId(userId),
                todayChecked
                        ? "오늘 출석을 완료했습니다."
                        : "오늘 아직 출석하지 않았습니다."
        );
    }

    private long calculateConsecutiveDays(
            Long userId
    ) {

        List<Attendance> attendances =
                attendanceRepository
                        .findByUserIdOrderByAttendanceDateDesc(
                                userId
                        );

        if (attendances.isEmpty()) {
            return 0L;
        }

        LocalDate today = LocalDate.now();

        LocalDate latestAttendanceDate =
                attendances
                        .get(0)
                        .getAttendanceDate();

        LocalDate expectedDate;

        if (latestAttendanceDate.equals(today)) {

            expectedDate = today;

        } else if (
                latestAttendanceDate.equals(
                        today.minusDays(1)
                )
        ) {

            expectedDate = today.minusDays(1);

        } else {

            return 0L;
        }

        long consecutiveDays = 0L;

        for (Attendance attendance : attendances) {

            if (
                    attendance
                            .getAttendanceDate()
                            .equals(expectedDate)
            ) {

                consecutiveDays++;

                expectedDate =
                        expectedDate.minusDays(1);

            } else {

                break;
            }
        }

        return consecutiveDays;
    }
}