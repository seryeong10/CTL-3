package com.baeumpay.backend.point.service;

import com.baeumpay.backend.point.dto.MissionDifficulty;
import com.baeumpay.backend.point.dto.PointHistoryResponse;
import com.baeumpay.backend.point.dto.PointRewardResponse;
import com.baeumpay.backend.point.entity.PointSourceType;
import com.baeumpay.backend.point.entity.PointTransaction;
import com.baeumpay.backend.point.entity.PointTransactionType;
import com.baeumpay.backend.point.entity.PointWallet;
import com.baeumpay.backend.point.repository.PointTransactionRepository;
import com.baeumpay.backend.point.repository.PointWalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PointService {

    private static final long DAILY_MISSION_REWARD_LIMIT = 3L;

    private final PointWalletRepository pointWalletRepository;
    private final PointTransactionRepository pointTransactionRepository;

    public PointWallet getWallet(Long userId) {

        return pointWalletRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "포인트 지갑을 찾을 수 없습니다."
                        )
                );
    }

    @Transactional
    public PointWallet createWallet(Long userId) {

        return pointWalletRepository.findByUserId(userId)
                .orElseGet(() ->
                        pointWalletRepository.save(
                                new PointWallet(userId)
                        )
                );
    }

    @Transactional
    public PointRewardResponse rewardMissionPoint(
            Long userId,
            Long missionId,
            MissionDifficulty difficulty
    ) {

        PointWallet wallet = getWallet(userId);

        LocalDate today = LocalDate.now();

        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.plusDays(1).atStartOfDay();

        long todayRewardCount =
                pointTransactionRepository
                        .countByUserIdAndTypeAndSourceTypeAndCreatedAtBetween(
                                userId,
                                PointTransactionType.EARN,
                                PointSourceType.MISSION,
                                startOfDay,
                                endOfDay
                        );

        if (todayRewardCount >= DAILY_MISSION_REWARD_LIMIT) {

            return new PointRewardResponse(
                    userId,
                    0L,
                    wallet.getBalance(),
                    todayRewardCount,
                    false,
                    "오늘의 미션 포인트 지급 횟수를 모두 사용했습니다."
            );
        }

        Long rewardPoint = calculateMissionReward(difficulty);

        wallet.earn(rewardPoint);

        PointTransaction transaction = new PointTransaction(
                userId,
                PointTransactionType.EARN,
                rewardPoint,
                PointSourceType.MISSION,
                missionId,
                "미션 성공 포인트"
        );

        pointTransactionRepository.save(transaction);

        long updatedRewardCount = todayRewardCount + 1;

        return new PointRewardResponse(
                userId,
                rewardPoint,
                wallet.getBalance(),
                updatedRewardCount,
                true,
                "미션 성공 포인트가 지급되었습니다."
        );
    }

    public List<PointHistoryResponse> getPointHistory(
            Long userId
    ) {

        return pointTransactionRepository
                .findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(PointHistoryResponse::from)
                .toList();
    }

    private Long calculateMissionReward(
            MissionDifficulty difficulty
    ) {

        return switch (difficulty) {
            case EASY -> 10L;
            case NORMAL -> 20L;
            case HARD -> 30L;
        };
    }
}