package com.baeumpay.backend.mission.repository;

import com.baeumpay.backend.mission.entity.MissionLog;
import com.baeumpay.backend.mission.entity.MissionLogStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MissionLogRepository extends JpaRepository<MissionLog, Long> {

    Optional<MissionLog> findFirstByUserIdAndMissionIdAndStatusOrderByCreatedAtDesc(
            Long userId,
            Long missionId,
            MissionLogStatus status
    );

    List<MissionLog> findByUserIdOrderByCreatedAtDesc(Long userId);

    long countByUserIdAndStatus(Long userId, MissionLogStatus status);
}
