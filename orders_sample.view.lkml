view: orders_sample {
  sql_table_name: `orders.orders_sample ` ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: created_at {
    type: time
    datatype: datetime
    timeframes: [date, week,day_of_week, day_of_week_index, month, month_num, year]
    sql: ${TABLE}.created_at ;;
  }

  measure: total_price {
    type: sum
    sql: ${TABLE}.price ;;
  }
}
