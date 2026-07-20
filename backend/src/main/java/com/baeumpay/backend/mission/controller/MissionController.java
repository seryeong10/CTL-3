package com.baeumpay.backend.mission.controller;

import com.baeumpay.backend.mission.dto.*;
import com.baeumpay.backend.mission.entity.MissionDifficulty;
import com.baeumpay.backend.mission.service.MissionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/missions")
public class MissionController {

    private final MissionService missionService;

    @PostMapping
    public MissionResponse createMission(@Valid @RequestBody MissionCreateRequest request) {
        return missionService.createMission(request);
    }

    @GetMapping
    public List<MissionResponse> getMissions(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) MissionDifficulty difficulty
    ) {
        return missionService.getMissions(category, difficulty);
    }

    @GetMapping("/{missionId}")
    public MissionDetailResponse getMission(@PathVariable Long missionId) {
        return missionService.getMission(missionId);
    }

    @PostMapping("/{missionId}/steps")
    public MissionStepResponse createMissionStep(
            @PathVariable Long missionId,
            @Valid @RequestBody MissionStepCreateRequest request
    ) {
        return missionService.createMissionStep(missionId, request);
    }

    @DeleteMapping("/{missionId}")
    public void deleteMission(@PathVariable Long missionId) {
        missionService.deleteMission(missionId);
    }
}
