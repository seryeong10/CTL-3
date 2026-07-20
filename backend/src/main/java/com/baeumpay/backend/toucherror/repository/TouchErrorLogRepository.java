package com.baeumpay.backend.toucherror.repository;

import com.baeumpay.backend.toucherror.entity.TouchErrorLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TouchErrorLogRepository extends JpaRepository<TouchErrorLog, Long> {

    List<TouchErrorLog> findByUserIdOrderByCreatedAtDesc(Long userId);
}
