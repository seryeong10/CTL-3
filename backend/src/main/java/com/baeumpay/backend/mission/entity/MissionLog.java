package com.baeumpay.backend.mission.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "mission_log")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MissionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long logId;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long missionId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private MissionLogStatus status;

    @Column(nullable = false)
    private Integer score;

    private LocalDateTime completedAt;

    @Column(nullable = false)
    private boolean pointRewarded;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public MissionLog(Long userId, Long missionId, MissionLogStatus status, Integer score) {
        this.userId = userId;
        this.missionId = missionId;
        this.status = status;
        this.score = score == null ? 0 : score;
        this.pointRewarded = false;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();

        if (status == MissionLogStatus.SUCCESS || status == MissionLogStatus.FAIL) {
            this.completedAt = LocalDateTime.now();
        }
    }

    public void updateStatus(MissionLogStatus status, Integer score) {
        this.status = status;
        if (score != null) {
            this.score = score;
        }
        if (status == MissionLogStatus.SUCCESS || status == MissionLogStatus.FAIL) {
            this.completedAt = LocalDateTime.now();
        }
        this.updatedAt = LocalDateTime.now();
    }

    public void markPointRewarded() {
        this.pointRewarded = true;
        this.updatedAt = LocalDateTime.now();
    }
}
