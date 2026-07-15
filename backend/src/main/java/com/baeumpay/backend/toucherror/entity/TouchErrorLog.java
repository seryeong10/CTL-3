package com.baeumpay.backend.toucherror.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "touch_error_log")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TouchErrorLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long errorId;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long missionId;

    @Column(nullable = false)
    private Long stepId;

    @Column(length = 100)
    private String wrongAction;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    public TouchErrorLog(Long userId, Long missionId, Long stepId, String wrongAction) {
        this.userId = userId;
        this.missionId = missionId;
        this.stepId = stepId;
        this.wrongAction = wrongAction;
        this.createdAt = LocalDateTime.now();
    }
}
