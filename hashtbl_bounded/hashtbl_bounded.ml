(* Hashtbl_bounded: implementation of hash tables with bounded bins. 

   Copyright Luca de Alfaro <lda@dealfaro.com>, 2007.
   Copyright 1996 Institut National de Recherche en Informatique et   
   en Automatique.    
   All rights reserved. 

   This file is distributed under the terms of the GNU Library General
   Public License, with the special exception on linking described in
   file LICENSE.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version,
   with the following special exception:

   You may link, statically or dynamically, a "work that uses the
   Library" with a publicly distributed version of the Library to
   produce an executable file containing portions of the Library, and
   distribute that executable file under terms of your choice, without
   any of the additional requirements listed in clause 6 of the GNU
   Library General Public License.  By "a publicly distributed version
   of the Library", we mean either the unmodified Library as
   distributed by INRIA, or a modified version of the Library that is
   distributed under the conditions defined in clause 2 of the GNU
   Library General Public License.  This exception does not however
   invalidate any other reasons why the executable file might be
   covered by the GNU Library General Public License.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   The GNU Library General Public License is available at
   http://www.gnu.org/copyleft/lgpl.html; to obtain it, you can also
   write to the Free Software Foundation, Inc., 59 Temple Place -
   Suite 330, Boston, MA 02111-1307, USA.
 *)


(* Derived from Hashtbl.ml
   Modified by Luca de Alfaro, to keep track of sizes of each bucket, and 
   prevent buckets getting too large.  Also implemented a function to remove
   all entries of a bucket. WARNING: if buckets grow too large, 
   data added to them is lost!  *)
   
(* Hash tables *)

external hash_param : int -> int -> 'a -> int = "caml_hash_univ_param" "noalloc"

let hash x = hash_param 10 100 x

(* We do dynamic hashing, and resize the table and rehash the elements
   when buckets become too long. *)

type ('a, 'b) t =
  { mutable size: int;                        (* number of elements *)
    max_bucket_size: int;                     (* max size of each bucket *)
    mutable data: ('a * 'b) list array }     (* the buckets, as a list *)

let create initial_size m =
  let s = min (max 1 initial_size) Sys.max_array_length in
  { size = 0; max_bucket_size = m; data = Array.make s [] }

let clear h =
  for i = 0 to Array.length h.data - 1 do
    h.data.(i) <- []
  done;
  h.size <- 0

let copy h =
  { size = h.size;
    max_bucket_size = h.max_bucket_size; 
    data = Array.copy h.data }

let length h = h.size

let resize hashfun tbl =
  let odata = tbl.data in
  let osize = Array.length odata in
  let nsize = min (2 * osize + 1) Sys.max_array_length in
  if nsize <> osize then begin
    let ndata = Array.create nsize [] in
    let rec insert_bucket = function
        [] -> ()
      | (key, data) :: rest ->
          insert_bucket rest; (* preserve original order of elements *)
          let nidx = (hashfun key) mod nsize in
          ndata.(nidx) <- (key, data) :: ndata.(nidx) in
    for i = 0 to osize - 1 do
      insert_bucket odata.(i)
    done;
    tbl.data <- ndata;
  end

(* This function checks that the max bucket len is not exceeded *)
let add h key info =
  let i = (hash key) mod (Array.length h.data) in
  if List.length (h.data.(i)) < h.max_bucket_size then begin 
    let bucket = (key, info) :: h.data.(i) in
    h.data.(i) <- bucket;
    h.size <- succ h.size;
    if h.size > Array.length h.data lsl 1 then resize hash h
  end

let remove h key =
  let rec remove_bucket = function
      [] -> []
    | (k, i) :: next ->
        if compare k key = 0
        then begin h.size <- pred h.size; next end
        else (k, i) :: (remove_bucket next) in
  let i = (hash key) mod (Array.length h.data) in
  h.data.(i) <- remove_bucket h.data.(i)

let remove_all h key =
  let rec remove_bucket_all = function
      [] -> []
    | (k, i) :: next ->
        if compare k key = 0
        then begin h.size <- pred h.size; remove_bucket_all next end
        else (k, i) :: (remove_bucket_all next) in
  let i = (hash key) mod (Array.length h.data) in
  h.data.(i) <- remove_bucket_all h.data.(i)

let rec find_rec key = function
    [] -> raise Not_found
  | (k, d) :: rest ->
      if compare key k = 0 then d else find_rec key rest

let find h key =
  match h.data.((hash key) mod (Array.length h.data)) with
    [] -> raise Not_found
  | (k1, d1) :: rest1 ->
      if compare key k1 = 0 then d1 else
      match rest1 with
        [] -> raise Not_found
      | (k2, d2) :: rest2 ->
          if compare key k2 = 0 then d2 else
          match rest2 with
            [] -> raise Not_found
          | (k3, d3) :: rest3 ->
              if compare key k3 = 0 then d3 else find_rec key rest3

let find_all h key =
  let rec find_in_bucket = function
    [] -> []
  | (k, d) :: rest ->
      if compare k key = 0
      then d :: find_in_bucket rest
      else find_in_bucket rest in
  find_in_bucket h.data.((hash key) mod (Array.length h.data))

let replace h key info =
  let rec replace_bucket = function
      [] -> raise Not_found
    | (k, i) :: next ->
        if compare k key = 0
        then (k, info) :: next
        else (k, i) :: (replace_bucket next) in
  let i = (hash key) mod (Array.length h.data) in
  let l = h.data.(i) in
  try
    h.data.(i) <- replace_bucket l
  with Not_found ->
    h.data.(i) <- (key, info) :: l;
    h.size <- succ h.size;
    if h.size > Array.length h.data lsl 1 then resize hash h

let mem h key =
  let rec mem_in_bucket = function
    [] -> false
  | (k, d) :: rest ->
      compare k key = 0 || mem_in_bucket rest in
  mem_in_bucket h.data.((hash key) mod (Array.length h.data))

let iter f h =
  let rec do_bucket = function
      [] -> ()
    | (k, d) :: rest ->
        f k d; do_bucket rest in
  let d = h.data in
  for i = 0 to Array.length d - 1 do
    do_bucket d.(i)
  done

let fold f h init =
  let rec do_bucket b accu =
    match b with
      [] -> accu
    | (k, d) :: rest ->
        do_bucket rest (f k d accu) in
  let d = h.data in
  let accu = ref init in
  for i = 0 to Array.length d - 1 do
    accu := do_bucket d.(i) !accu
  done;
  !accu

(* Functorial interface *)

module type HashedType =
  sig
    type t
    val equal: t -> t -> bool
    val hash: t -> int
  end

module type S =
  sig
    type key
    type 'a t
    val create: int -> int -> 'a t
    val clear: 'a t -> unit
    val copy: 'a t -> 'a t
    val add: 'a t -> key -> 'a -> unit
    val remove: 'a t -> key -> unit
    val remove_all: 'a t -> key -> unit
    val find: 'a t -> key -> 'a
    val find_all: 'a t -> key -> 'a list
    val replace : 'a t -> key -> 'a -> unit
    val mem : 'a t -> key -> bool
    val iter: (key -> 'a -> unit) -> 'a t -> unit
    val fold: (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val length: 'a t -> int
  end

module Make(H: HashedType): (S with type key = H.t) =
  struct
    type key = H.t
    type 'a hashtbl = (key, 'a) t
    type 'a t = 'a hashtbl
    let create = create
    let clear = clear
    let copy = copy

    let safehash key = (H.hash key) land max_int

    let add h key info =
      let i = (safehash key) mod (Array.length h.data) in
      if List.length (h.data.(i)) < h.max_bucket_size then begin 
	let bucket = (key, info) :: h.data.(i) in
	h.data.(i) <- bucket;
	h.size <- succ h.size;
	if h.size > Array.length h.data lsl 1 then resize safehash h
      end

    let remove h key =
      let rec remove_bucket = function
          [] -> []
        | (k, i) :: next ->
            if H.equal k key
            then begin h.size <- pred h.size; next end
            else (k, i) :: (remove_bucket next) in
      let i = (safehash key) mod (Array.length h.data) in
      h.data.(i) <- remove_bucket h.data.(i)

    let remove_all h key =
      let rec remove_bucket_all = function
	  [] -> []
	| (k, i) :: next ->
            if compare k key = 0
            then begin h.size <- pred h.size; remove_bucket_all next end
            else (k, i) :: (remove_bucket_all next) in
      let i = (hash key) mod (Array.length h.data) in
      h.data.(i) <- remove_bucket_all h.data.(i)

    let rec find_rec key = function
        [] -> raise Not_found
      | (k, d) :: rest ->
          if H.equal key k then d else find_rec key rest

    let find h key =
      match h.data.((safehash key) mod (Array.length h.data)) with
        [] -> raise Not_found
      | (k1, d1) :: rest1 ->
          if H.equal key k1 then d1 else
          match rest1 with
            [] -> raise Not_found
          | (k2, d2) :: rest2 ->
              if H.equal key k2 then d2 else
              match rest2 with
                [] -> raise Not_found
              | (k3, d3) :: rest3 ->
                  if H.equal key k3 then d3 else find_rec key rest3

    let find_all h key =
      let rec find_in_bucket = function
        [] -> []
      | (k, d) :: rest ->
          if H.equal k key
          then d :: find_in_bucket rest
          else find_in_bucket rest in
      find_in_bucket h.data.((safehash key) mod (Array.length h.data))

    let replace h key info =
      let rec replace_bucket = function
          [] ->
            raise Not_found
        | (k, i) :: next ->
            if H.equal k key
            then (k, info) :: next
            else (k, i) :: (replace_bucket next) in
      let i = (safehash key) mod (Array.length h.data) in
      let l = h.data.(i) in
      try
        h.data.(i) <- replace_bucket l
      with Not_found ->
        h.data.(i) <- (key, info) :: l;
        h.size <- succ h.size;
        if h.size > Array.length h.data lsl 1 then resize safehash h

    let mem h key =
      let rec mem_in_bucket = function
      | [] -> false
      | (k, d) :: rest ->
          H.equal k key || mem_in_bucket rest in
      mem_in_bucket h.data.((safehash key) mod (Array.length h.data))

    let iter = iter
    let fold = fold
    let length = length
  end


