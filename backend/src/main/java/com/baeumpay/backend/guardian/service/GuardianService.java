package com.baeumpay.backend.guardian.service;

import com.baeumpay.backend.guardian.dto.*;
import com.baeumpay.backend.guardian.entity.GuardianLink;
import com.baeumpay.backend.guardian.repository.GuardianLinkRepository;
import com.baeumpay.backend.mission.entity.MissionLogStatus;
import com.baeumpay.backend.mission.repository.MissionLogRepository;
import com.baeumpay.backend.point.entity.PointWallet;
import com.baeumpay.backend.point.service.PointService;
import com.baeumpay.backend.user.entity.User;
import com.baeumpay.backend.user.entity.UserType;
import com.baeumpay.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class GuardianService {

    private final GuardianLinkRepository guardianLinkRepository;
    private final UserRepository userRepository;
    private final PointService pointService;
    private final MissionLogRepository missionLogRepository;

    @Transactional
    public GuardianLinkResponse linkSenior(Long guardianUserId, GuardianLinkCreateRequest request) {
        User guardian = getUser(guardianUserId);
        User senior = getUser(request.seniorUserId());

        if (guardian.getUserType() != UserType.GUARDIAN) {
            throw new IllegalArgumentException("보호자 유형의 사용자만 시니어를 연결할 수 있습니다.");
        }

        if (senior.getUserType() != UserType.SENIOR) {
            throw new IllegalArgumentException("연결 대상 사용자는 시니어 유형이어야 합니다.");
        }

        GuardianLink link = guardianLinkRepository
                .findByGuardianUserIdAndSeniorUserId(guardianUserId, request.seniorUserId())
                .orElseGet(() -> guardianLinkRepository.save(
                        new GuardianLink(guardianUserId, request.seniorUserId(), request.relation())
                ));

        return GuardianLinkResponse.from(link);
    }

    public List<GuardianSeniorResponse> getMySeniors(Long guardianUserId) {
        User guardian = getUser(guardianUserId);
        if (guardian.getUserType() != UserType.GUARDIAN) {
            throw new IllegalArgumentException("보호자 유형의 사용자만 조회할 수 있습니다.");
        }

        return guardianLinkRepository.findByGuardianUserIdOrderByCreatedAtDesc(guardianUserId)
                .stream()
                .map(this::toGuardianSeniorResponse)
                .toList();
    }

    public List<SeniorGuardianResponse> getMyGuardians(Long seniorUserId) {
        User senior = getUser(seniorUserId);
        if (senior.getUserType() != UserType.SENIOR) {
            throw new IllegalArgumentException("시니어 유형의 사용자만 조회할 수 있습니다.");
        }

        return guardianLinkRepository.findBySeniorUserIdOrderByCreatedAtDesc(seniorUserId)
                .stream()
                .map(this::toSeniorGuardianResponse)
                .toList();
    }

    private GuardianSeniorResponse toGuardianSeniorResponse(GuardianLink link) {
        User senior = getUser(link.getSeniorUserId());
        Long walletBalance = getWalletBalance(senior.getUserId());

        long totalAttempts = missionLogRepository.findByUserIdOrderByCreatedAtDesc(senior.getUserId()).size();
        long successCount = missionLogRepository.countByUserIdAndStatus(senior.getUserId(), MissionLogStatus.SUCCESS);
        double successRate = totalAttempts == 0 ? 0.0 : Math.round((successCount * 1000.0 / totalAttempts)) / 10.0;

        return new GuardianSeniorResponse(
                link.getLinkId(),
                link.getRelation(),
                link.getCreatedAt(),
                senior.getUserId(),
                senior.getName(),
                senior.getPhone(),
                senior.getBirthYear(),
                walletBalance,
                new MissionStatsResponse(totalAttempts, successCount, successRate)
        );
    }

    private SeniorGuardianResponse toSeniorGuardianResponse(GuardianLink link) {
        User guardian = getUser(link.getGuardianUserId());

        return new SeniorGuardianResponse(
                link.getLinkId(),
                link.getRelation(),
                guardian.getUserId(),
                guardian.getName(),
                guardian.getPhone(),
                link.getCreatedAt()
        );
    }

    private User getUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }

    private Long getWalletBalance(Long userId) {
        try {
            PointWallet wallet = pointService.getWallet(userId);
            return wallet.getBalance();
        } catch (IllegalArgumentException e) {
            return 0L;
        }
    }
}
