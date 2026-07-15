package com.baeumpay.backend.mission.service;

import com.baeumpay.backend.mission.dto.*;
import com.baeumpay.backend.mission.entity.Mission;
import com.baeumpay.backend.mission.entity.MissionDifficulty;
import com.baeumpay.backend.mission.entity.MissionStep;
import com.baeumpay.backend.mission.repository.MissionRepository;
import com.baeumpay.backend.mission.repository.MissionStepRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MissionService {

    private final MissionRepository missionRepository;
    private final MissionStepRepository missionStepRepository;

    @Transactional
    public MissionResponse createMission(MissionCreateRequest request) {
        Long rewardPoint = request.rewardPoint() == null
                ? defaultRewardPoint(request.difficulty())
                : request.rewardPoint();

        Mission mission = new Mission(
                request.title(),
                request.description(),
                request.category(),
                request.difficulty(),
                rewardPoint
        );

        return MissionResponse.from(missionRepository.save(mission));
    }

    public List<MissionResponse> getMissions(String category, MissionDifficulty difficulty) {
        List<Mission> missions;

        if (category != null && difficulty != null) {
            missions = missionRepository.findByActiveTrueOrderByCreatedAtDesc()
                    .stream()
                    .filter(mission -> category.equals(mission.getCategory()))
                    .filter(mission -> difficulty == mission.getDifficulty())
                    .toList();
        } else if (category != null) {
            missions = missionRepository.findByCategoryAndActiveTrueOrderByCreatedAtDesc(category);
        } else if (difficulty != null) {
            missions = missionRepository.findByDifficultyAndActiveTrueOrderByCreatedAtDesc(difficulty);
        } else {
            missions = missionRepository.findByActiveTrueOrderByCreatedAtDesc();
        }

        return missions.stream()
                .map(MissionResponse::from)
                .toList();
    }

    public Mission getMissionEntity(Long missionId) {
        return missionRepository.findByMissionIdAndActiveTrue(missionId)
                .orElseThrow(() -> new IllegalArgumentException("미션을 찾을 수 없습니다."));
    }

    public MissionDetailResponse getMission(Long missionId) {
        Mission mission = getMissionEntity(missionId);
        List<MissionStep> steps = missionStepRepository.findByMissionIdOrderByStepOrderAsc(missionId);
        return MissionDetailResponse.from(mission, steps);
    }

    @Transactional
    public MissionStepResponse createMissionStep(Long missionId, MissionStepCreateRequest request) {
        getMissionEntity(missionId);

        MissionStep step = new MissionStep(
                missionId,
                request.stepOrder(),
                request.instructionText(),
                request.correctAction(),
                request.voiceGuideText()
        );

        return MissionStepResponse.from(missionStepRepository.save(step));
    }

    @Transactional
    public void deleteMission(Long missionId) {
        Mission mission = getMissionEntity(missionId);
        mission.deactivate();
    }

    private Long defaultRewardPoint(MissionDifficulty difficulty) {
        return switch (difficulty) {
            case EASY -> 10L;
            case NORMAL -> 20L;
            case HARD -> 30L;
        };
    }
}
