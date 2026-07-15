package com.baeumpay.backend.guardian.repository;

import com.baeumpay.backend.guardian.entity.GuardianLink;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GuardianLinkRepository extends JpaRepository<GuardianLink, Long> {

    Optional<GuardianLink> findByGuardianUserIdAndSeniorUserId(Long guardianUserId, Long seniorUserId);

    List<GuardianLink> findByGuardianUserIdOrderByCreatedAtDesc(Long guardianUserId);

    List<GuardianLink> findBySeniorUserIdOrderByCreatedAtDesc(Long seniorUserId);
}
