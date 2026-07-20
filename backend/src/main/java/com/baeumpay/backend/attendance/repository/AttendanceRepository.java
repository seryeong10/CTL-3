package com.baeumpay.backend.attendance.repository;

import com.baeumpay.backend.attendance.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AttendanceRepository
        extends JpaRepository<Attendance, Long> {

    Optional<Attendance> findByUserIdAndAttendanceDate(
            Long userId,
            LocalDate attendanceDate
    );

    List<Attendance> findByUserIdOrderByAttendanceDateDesc(
            Long userId
    );

    long countByUserId(
            Long userId
    );
}