open! Core
open! Async
open! Import

let normalize str = String.lowercase str |> String.strip