package com.baeumpay.backend.mission.controller;

import com.baeumpay.backend.mission.dto.MissionLogCreateRequest;
import com.baeumpay.backend.mission.dto.MissionLogResponse;
import com.baeumpay.backend.mission.dto.MissionLogUpdateRequest;
import com.baeumpay.backend.mission.service.MissionLogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/mission-logs")
public class MissionLogController {

    private final MissionLogService missionLogService;

    @PostMapping("/users/{userId}")
    public MissionLogResponse createOrUpdateMissionLog(
            @PathVariable Long userId,
            @Valid @RequestBody MissionLogCreateRequest request
    ) {
        return missionLogService.createOrUpdateMissionLog(userId, request);
    }

    @PatchMapping("/{logId}")
    public MissionLogResponse updateMissionLog(
            @PathVariable Long logId,
            @Valid @RequestBody MissionLogUpdateRequest request
    ) {
        return missionLogService.updateMissionLog(logId, request);
    }

    @GetMapping("/users/{userId}")
    public List<MissionLogResponse> getUserMissionLogs(@PathVariable Long userId) {
        return missionLogService.getUserMissionLogs(userId);
    }
}
