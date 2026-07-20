package com.baeumpay.backend.mission.repository;

import com.baeumpay.backend.mission.entity.MissionStep;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MissionStepRepository extends JpaRepository<MissionStep, Long> {

    List<MissionStep> findByMissionIdOrderByStepOrderAsc(Long missionId);
}
