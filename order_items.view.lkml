view: order_items {
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension: order_id {
    type: number
# hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: []
    convert_tz: no
    sql: ${TABLE}.returned_at ;;
  }


  dimension: inventory_item_id {
    type: number
# hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: sale_price {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.sale_price ;;
  }

  measure: count {
    type: count
    drill_fields: [id, inventory_items.id, orders.id]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: total_gross_profit {
    label: "Total Gross Margin"
    type: sum
    sql: (${sale_price} - ${inventory_items.cost}) ;;
    value_format: "$#,##0.00"
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }
}
