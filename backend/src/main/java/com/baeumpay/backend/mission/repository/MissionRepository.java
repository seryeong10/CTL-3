package com.baeumpay.backend.mission.repository;

import com.baeumpay.backend.mission.entity.Mission;
import com.baeumpay.backend.mission.entity.MissionDifficulty;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MissionRepository extends JpaRepository<Mission, Long> {

    Optional<Mission> findByMissionIdAndActiveTrue(Long missionId);

    List<Mission> findByActiveTrueOrderByCreatedAtDesc();

    List<Mission> findByCategoryAndActiveTrueOrderByCreatedAtDesc(String category);

    List<Mission> findByDifficultyAndActiveTrueOrderByCreatedAtDesc(MissionDifficulty difficulty);
}
