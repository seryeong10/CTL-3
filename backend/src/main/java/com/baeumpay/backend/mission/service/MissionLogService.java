package com.baeumpay.backend.mission.service;

import com.baeumpay.backend.mission.dto.MissionLogCreateRequest;
import com.baeumpay.backend.mission.dto.MissionLogResponse;
import com.baeumpay.backend.mission.dto.MissionLogUpdateRequest;
import com.baeumpay.backend.mission.entity.Mission;
import com.baeumpay.backend.mission.entity.MissionDifficulty;
import com.baeumpay.backend.mission.entity.MissionLog;
import com.baeumpay.backend.mission.entity.MissionLogStatus;
import com.baeumpay.backend.mission.repository.MissionLogRepository;
import com.baeumpay.backend.point.dto.PointRewardResponse;
import com.baeumpay.backend.point.service.PointService;
import com.baeumpay.backend.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MissionLogService {

    private final MissionLogRepository missionLogRepository;
    private final MissionService missionService;
    private final UserService userService;
    private final PointService pointService;

    @Transactional
    public MissionLogResponse createOrUpdateMissionLog(Long userId, MissionLogCreateRequest request) {
        userService.getUserEntity(userId);
        Mission mission = missionService.getMissionEntity(request.missionId());

        MissionLogStatus status = request.status() == null
                ? MissionLogStatus.IN_PROGRESS
                : request.status();

        MissionLog log = missionLogRepository
                .findFirstByUserIdAndMissionIdAndStatusOrderByCreatedAtDesc(
                        userId,
                        request.missionId(),
                        MissionLogStatus.IN_PROGRESS
                )
                .orElseGet(() -> missionLogRepository.save(
                        new MissionLog(userId, request.missionId(), MissionLogStatus.IN_PROGRESS, request.score())
                ));

        log.updateStatus(status, request.score());

        String message = rewardPointIfNeeded(log, mission);
        return MissionLogResponse.from(log, message);
    }

    @Transactional
    public MissionLogResponse updateMissionLog(Long logId, MissionLogUpdateRequest request) {
        MissionLog log = missionLogRepository.findById(logId)
                .orElseThrow(() -> new IllegalArgumentException("미션 수행 로그를 찾을 수 없습니다."));

        Mission mission = missionService.getMissionEntity(log.getMissionId());

        log.updateStatus(request.status(), request.score());

        String message = rewardPointIfNeeded(log, mission);
        return MissionLogResponse.from(log, message);
    }

    public List<MissionLogResponse> getUserMissionLogs(Long userId) {
        userService.getUserEntity(userId);

        return missionLogRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(log -> MissionLogResponse.from(log, null))
                .toList();
    }

    public long countUserMissionLogsByStatus(Long userId, MissionLogStatus status) {
        return missionLogRepository.countByUserIdAndStatus(userId, status);
    }

    private String rewardPointIfNeeded(MissionLog log, Mission mission) {
        if (log.getStatus() != MissionLogStatus.SUCCESS) {
            return "미션 수행 로그가 저장되었습니다.";
        }

        if (log.isPointRewarded()) {
            return "이미 포인트가 지급된 미션 수행 로그입니다.";
        }

        PointRewardResponse rewardResponse = pointService.rewardMissionPoint(
                log.getUserId(),
                mission.getMissionId(),
                toPointDifficulty(mission.getDifficulty())
        );

        if (rewardResponse.rewardGranted()) {
            log.markPointRewarded();
        }

        return rewardResponse.message();
    }

    private com.baeumpay.backend.point.dto.MissionDifficulty toPointDifficulty(
            MissionDifficulty difficulty
    ) {
        return switch (difficulty) {
            case EASY -> com.baeumpay.backend.point.dto.MissionDifficulty.EASY;
            case NORMAL -> com.baeumpay.backend.point.dto.MissionDifficulty.NORMAL;
            case HARD -> com.baeumpay.backend.point.dto.MissionDifficulty.HARD;
        };
    }
}
