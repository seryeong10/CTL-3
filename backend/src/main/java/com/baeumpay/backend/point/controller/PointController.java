package com.baeumpay.backend.point.controller;

import com.baeumpay.backend.point.dto.MissionPointRequest;
import com.baeumpay.backend.point.dto.PointHistoryResponse;
import com.baeumpay.backend.point.dto.PointResponse;
import com.baeumpay.backend.point.dto.PointRewardResponse;
import com.baeumpay.backend.point.entity.PointWallet;
import com.baeumpay.backend.point.service.PointService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/points")
public class PointController {

    private final PointService pointService;

    @PostMapping("/wallets/{userId}")
    public PointResponse createWallet(
            @PathVariable Long userId
    ) {

        PointWallet wallet =
                pointService.createWallet(userId);

        return PointResponse.from(wallet);
    }

    @GetMapping("/{userId}")
    public PointResponse getPoint(
            @PathVariable Long userId
    ) {

        PointWallet wallet =
                pointService.getWallet(userId);

        return PointResponse.from(wallet);
    }

    /*
     * TODO 백엔드 1 Mission/MissionAttempt 연동 후
     * 제거 또는 내부 호출 구조로 변경
     *
     * 현재 미션 포인트 기능 독립 테스트용 API.
     *
     * 최종 구조:
     * MissionAttempt SUCCESS
     * -> 서버에서 Mission 난이도 조회
     * -> PointService.rewardMissionPoint 호출
     *
     * 클라이언트가 난이도를 직접 전달하면 안 됨.
     */
    @PostMapping("/{userId}/mission-reward")
    public PointRewardResponse rewardMissionPoint(
            @PathVariable Long userId,
            @Valid @RequestBody MissionPointRequest request
    ) {

        return pointService.rewardMissionPoint(
                userId,
                request.missionId(),
                request.difficulty()
        );
    }

    @GetMapping("/{userId}/history")
    public List<PointHistoryResponse> getPointHistory(
            @PathVariable Long userId
    ) {

        return pointService.getPointHistory(userId);
    }
}