package com.baeumpay.backend.attendance.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "attendance",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_attendance_user_date",
                        columnNames = {
                                "user_id",
                                "attendance_date"
                        }
                )
        }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Attendance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long attendanceId;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private LocalDate attendanceDate;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    public Attendance(
            Long userId,
            LocalDate attendanceDate
    ) {
        this.userId = userId;
        this.attendanceDate = attendanceDate;
        this.createdAt = LocalDateTime.now();
    }
}