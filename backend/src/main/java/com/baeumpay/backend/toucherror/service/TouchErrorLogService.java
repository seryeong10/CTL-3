package com.baeumpay.backend.toucherror.service;

import com.baeumpay.backend.mission.repository.MissionRepository;
import com.baeumpay.backend.mission.repository.MissionStepRepository;
import com.baeumpay.backend.toucherror.dto.TouchErrorLogCreateRequest;
import com.baeumpay.backend.toucherror.dto.TouchErrorLogResponse;
import com.baeumpay.backend.toucherror.entity.TouchErrorLog;
import com.baeumpay.backend.toucherror.repository.TouchErrorLogRepository;
import com.baeumpay.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TouchErrorLogService {

    private final TouchErrorLogRepository touchErrorLogRepository;
    private final UserRepository userRepository;
    private final MissionRepository missionRepository;
    private final MissionStepRepository missionStepRepository;

    @Transactional
    public TouchErrorLogResponse createTouchErrorLog(Long userId, TouchErrorLogCreateRequest request) {
        if (!userRepository.existsById(userId)) {
            throw new IllegalArgumentException("사용자를 찾을 수 없습니다.");
        }

        if (!missionRepository.existsById(request.missionId())) {
            throw new IllegalArgumentException("미션을 찾을 수 없습니다.");
        }

        if (!missionStepRepository.existsById(request.stepId())) {
            throw new IllegalArgumentException("미션 단계를 찾을 수 없습니다.");
        }

        TouchErrorLog log = touchErrorLogRepository.save(
                new TouchErrorLog(
                        userId,
                        request.missionId(),
                        request.stepId(),
                        request.wrongAction()
                )
        );

        return TouchErrorLogResponse.from(log);
    }

    public List<TouchErrorLogResponse> getUserErrorLogs(Long userId) {
        if (!userRepository.existsById(userId)) {
            throw new IllegalArgumentException("사용자를 찾을 수 없습니다.");
        }

        return touchErrorLogRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(TouchErrorLogResponse::from)
                .toList();
    }
}
