extends Node

signal card_clicked(card: Card)
signal card_play_requested(card: Card)
signal card_sell_requested(card: Card)
signal close_side_bar

var is_side_bar_open = false
