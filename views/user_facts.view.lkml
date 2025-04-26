view: user_facts {
    derived_table: {
        sql:
        with user_orders as (
        select
        u.id as user_id,
        count(distinct oi.order_id) as total_orders,
        sum(oi.sale_price) as total_spent,
        avg(oi.sale_price) as average_order_value,
        min(oi.created_at) as first_order_date,
        max(oi.created_at) as last_order_date,
        count(distinct oi.inventory_item_id) as unique_items_purchased
        from ${users.SQL_TABLE_NAME} u
        left join ${order_items.SQL_TABLE_NAME} oi on u.id = oi.user_id
        group by 1
        ),

        user_events as (
        select
        user_id,
        count(case when created_at >= date_add(current_timestamp, INTERVAL -7 DAY) then 1 end) as events_last_7_days,
        count(case when created_at >= date_add(current_timestamp, INTERVAL -30 DAY) then 1 end) as events_last_30_days,
        count(case when created_at >= date_add(current_timestamp, INTERVAL -60 DAY) then 1 end) as events_last_60_days,
        count(case when created_at >= date_add(current_timestamp, INTERVAL -90 DAY) then 1 end) as events_last_90_days,
        count(*) as total_events,
        min(created_at) as first_event_date,
        max(created_at) as last_event_date
        from ${events.SQL_TABLE_NAME}
        group by user_id
        ),

        user_metrics as (
        select
        user_id,
        date_diff(last_order_date, first_order_date, DAY) as days_between_first_and_last_order,
        case
        when total_orders > 0 then date_diff(last_order_date, first_order_date, DAY) / total_orders
        else null
        end as average_days_between_orders
        from user_orders
        )

        select
        uo.user_id,
        uo.total_orders,
        uo.total_spent,
        uo.average_order_value,
        uo.first_order_date,
        uo.last_order_date,
        uo.unique_items_purchased,
        um.days_between_first_and_last_order,
        um.average_days_between_orders,
        coalesce(ue.events_last_7_days, 0) as events_last_7_days,
        coalesce(ue.events_last_30_days, 0) as events_last_30_days,
        coalesce(ue.events_last_60_days, 0) as events_last_60_days,
        coalesce(ue.events_last_90_days, 0) as events_last_90_days,
        coalesce(ue.total_events, 0) as total_events,
        ue.first_event_date,
        ue.last_event_date,
        case
        when total_orders >= 5 then 'Frequent'
        when total_orders >= 2 then 'Regular'
        else 'Occasional'
        end as customer_segment
        from user_orders uo
        left join user_metrics um on uo.user_id = um.user_id
        left join user_events ue on uo.user_id = ue.user_id ;;
    }

    dimension: user_id {
        type: number
        primary_key: yes
        sql: ${TABLE}.user_id ;;
    }

    dimension: first_order_date {
        type: time
        sql: ${TABLE}.first_order_date ;;
    }

    dimension: last_order_date {
        type: time
        sql: ${TABLE}.last_order_date ;;
    }

    dimension: first_event_date {
        type: time
        sql: ${TABLE}.first_event_date ;;
    }

    dimension: last_event_date {
        type: time
        sql: ${TABLE}.last_event_date ;;
    }

    dimension: customer_segment {
        type: string
        sql: ${TABLE}.customer_segment ;;
    }

    measure: total_orders {
        type: sum
        sql: ${TABLE}.total_orders ;;
    }

    measure: total_spent {
        type: sum
        sql: ${TABLE}.total_spent ;;
    }

    measure: average_order_value {
        type: average
        sql: ${TABLE}.average_order_value ;;
    }

    measure: unique_items_purchased {
        type: sum
        sql: ${TABLE}.unique_items_purchased ;;
    }

    measure: days_between_first_and_last_order {
        type: average
        sql: ${TABLE}.days_between_first_and_last_order ;;
    }

    measure: average_days_between_orders {
        type: average
        sql: ${TABLE}.average_days_between_orders ;;
    }

    measure: events_last_7_days {
        type: sum
        sql: ${TABLE}.events_last_7_days ;;
    }

    measure: events_last_30_days {
        type: sum
        sql: ${TABLE}.events_last_30_days ;;
    }

    measure: events_last_60_days {
        type: sum
        sql: ${TABLE}.events_last_60_days ;;
    }

    measure: events_last_90_days {
        type: sum
        sql: ${TABLE}.events_last_90_days ;;
    }

    measure: total_events {
        type: sum
        sql: ${TABLE}.total_events ;;
    }
}