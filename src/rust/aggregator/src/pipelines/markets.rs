use anyhow::anyhow;
use chrono::{DateTime, Duration, Utc};
use sqlx::PgPool;

use aggregator::{Pipeline, PipelineAggregationResult, PipelineError};

pub struct MarketsRegisteredPerDay {
    pool: PgPool,
    last_indexed_timestamp: Option<DateTime<Utc>>,
}

#[allow(dead_code)]
impl MarketsRegisteredPerDay {
    pub fn new(pool: PgPool) -> Self {
        Self {
            pool,
            last_indexed_timestamp: None,
        }
    }
}

#[async_trait::async_trait]
impl Pipeline for MarketsRegisteredPerDay {
    fn model_name(&self) -> String {
        String::from("MarketsRegisteredPerDay")
    }

    fn ready(&self) -> bool {
        self.last_indexed_timestamp.is_none()
            || self.last_indexed_timestamp.unwrap() + Duration::days(1) < Utc::now()
    }

    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult {
        sqlx::query!(
            r#"
                INSERT INTO aggregator.markets_registered_per_day (markets, date)
                SELECT COUNT(*), time::date
                FROM market_registration_events
                WHERE time::date NOT IN (
                    SELECT date FROM aggregator.markets_registered_per_day
                )
                GROUP BY time::date
            "#
        )
        .execute(&self.pool)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }

    fn poll_interval(&self) -> Option<std::time::Duration> {
        Some(std::time::Duration::from_secs(60 * 60))
    }

    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult {
        let date = Utc::now().date_naive() - Duration::days(1);
        sqlx::query!(
            r#"
                INSERT INTO aggregator.markets_registered_per_day (date, markets)
                VALUES ($1, (
                    SELECT COUNT(*) as count
                    FROM market_registration_events
                    WHERE time::date = $1
                ))
            "#,
            date
        )
        .execute(&self.pool)
        .await
        .map_err(|e| PipelineError::ProcessingError(anyhow!(e)))?;
        Ok(())
    }
}
