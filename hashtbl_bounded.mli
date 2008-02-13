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

(** Hash tables and hash functions.

   Hash tables are hashed association tables, with in-place modification. 
*)


(** {6 Generic interface} *)


type ('a, 'b) t
(** The type of hash tables from type ['a] to type ['b]. *)

val create : int -> int -> ('a, 'b) t
(** [Hashtbl.create n m] creates a new, empty hash table, with initial
    size [n], and where each bucket can hold at most [m] elements.
    When more than m elements map to the same bucket, they are
    DISCARDED. For best results, [n] should be on the order of the
    expected number of elements that will be in the table.  The table
    grows as needed, so [n] is just an initial guess.  The limit [m] on
    bucket size is there to prevent stack overflows if too many
    elements map to the same bucket. *)

val clear : ('a, 'b) t -> unit
  (** Empty a hash table. *)


val add : ('a, 'b) t -> 'a -> 'b -> unit
(** [Hashtbl.add tbl x y] adds a binding of [x] to [y] in table [tbl].
   Previous bindings for [x] are not removed, but simply
   hidden. That is, after performing {!Hashtbl.remove}[ tbl x],
   the previous binding for [x], if any, is restored.
   (Same behavior as with association lists.) *)

val copy : ('a, 'b) t -> ('a, 'b) t
(** Return a copy of the given hashtable. *)

val find : ('a, 'b) t -> 'a -> 'b
(** [Hashtbl.find tbl x] returns the current binding of [x] in [tbl],
   or raises [Not_found] if no such binding exists. *)

val find_all : ('a, 'b) t -> 'a -> 'b list
(** [Hashtbl.find_all tbl x] returns the list of all data
   associated with [x] in [tbl].
   The current binding is returned first, then the previous
   bindings, in reverse order of introduction in the table. *)

val mem : ('a, 'b) t -> 'a -> bool
(** [Hashtbl.mem tbl x] checks if [x] is bound in [tbl]. *)

val remove : ('a, 'b) t -> 'a -> unit
(** [Hashtbl.remove tbl x] removes the current binding of [x] in [tbl],
   restoring the previous binding if it exists.
   It does nothing if [x] is not bound in [tbl]. *)

val remove_all : ('a, 'b) t -> 'a -> unit
(** [Hashtbl.remove tbl x] removes all bindings of [x] in [tbl].
   It does nothing if [x] is not bound in [tbl]. *)

val replace : ('a, 'b) t -> 'a -> 'b -> unit
(** [Hashtbl.replace tbl x y] replaces the current binding of [x]
   in [tbl] by a binding of [x] to [y].  If [x] is unbound in [tbl],
   a binding of [x] to [y] is added to [tbl].
   This is functionally equivalent to {!Hashtbl.remove}[ tbl x]
   followed by {!Hashtbl.add}[ tbl x y]. *)

val iter : ('a -> 'b -> unit) -> ('a, 'b) t -> unit
(** [Hashtbl.iter f tbl] applies [f] to all bindings in table [tbl].
   [f] receives the key as first argument, and the associated value
   as second argument. Each binding is presented exactly once to [f].
   The order in which the bindings are passed to [f] is unspecified.
   However, if the table contains several bindings for the same key,
   they are passed to [f] in reverse order of introduction, that is,
   the most recent binding is passed first. *)

val fold : ('a -> 'b -> 'c -> 'c) -> ('a, 'b) t -> 'c -> 'c
(** [Hashtbl.fold f tbl init] computes
   [(f kN dN ... (f k1 d1 init)...)],
   where [k1 ... kN] are the keys of all bindings in [tbl],
   and [d1 ... dN] are the associated values.
   Each binding is presented exactly once to [f].
   The order in which the bindings are passed to [f] is unspecified.
   However, if the table contains several bindings for the same key,
   they are passed to [f] in reverse order of introduction, that is,
   the most recent binding is passed first. *)


val length : ('a, 'b) t -> int
(** [Hashtbl.length tbl] returns the number of bindings in [tbl]. 
   Multiple bindings are counted multiply, so [Hashtbl.length] 
   gives the number of times [Hashtbl.iter] calls it first argument. *)


(** {6 Functorial interface} *)


module type HashedType =
  sig
    type t
      (** The type of the hashtable keys. *)
    val equal : t -> t -> bool
      (** The equality predicate used to compare keys. *)
    val hash : t -> int
      (** A hashing function on keys. It must be such that if two keys are
          equal according to [equal], then they have identical hash values
          as computed by [hash].
          Examples: suitable ([equal], [hash]) pairs for arbitrary key
          types include
          ([(=)], {!Hashtbl.hash}) for comparing objects by structure,
          ([(fun x y -> compare x y = 0)], {!Hashtbl.hash})
          for comparing objects by structure and handling {!Pervasives.nan}
          correctly, and
          ([(==)], {!Hashtbl.hash}) for comparing objects by addresses
          (e.g. for cyclic keys). *)
   end
(** The input signature of the functor {!Hashtbl.Make}. *)

module type S =
  sig
    type key
    type 'a t
    val create : int -> int -> 'a t
    val clear : 'a t -> unit
    val copy : 'a t -> 'a t
    val add : 'a t -> key -> 'a -> unit
    val remove : 'a t -> key -> unit
    val remove_all : 'a t -> key -> unit
    val find : 'a t -> key -> 'a
    val find_all : 'a t -> key -> 'a list
    val replace : 'a t -> key -> 'a -> unit
    val mem : 'a t -> key -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val length : 'a t -> int
  end
(** The output signature of the functor {!Hashtbl.Make}. *)

module Make (H : HashedType) : S with type key = H.t
(** Functor building an implementation of the hashtable structure.
    The functor [Hashtbl.Make] returns a structure containing
    a type [key] of keys and a type ['a t] of hash tables
    associating data of type ['a] to keys of type [key].
    The operations perform similarly to those of the generic
    interface, but use the hashing and equality functions
    specified in the functor argument [H] instead of generic
    equality and hashing. *)


(** {6 The polymorphic hash primitive} *)


val hash : 'a -> int
(** [Hashtbl.hash x] associates a positive integer to any value of
   any type. It is guaranteed that
   if [x = y] or [Pervasives.compare x y = 0], then [hash x = hash y]. 
   Moreover, [hash] always terminates, even on cyclic
   structures. *)

external hash_param : int -> int -> 'a -> int = "caml_hash_univ_param" "noalloc"
(** [Hashtbl.hash_param n m x] computes a hash value for [x], with the
   same properties as for [hash]. The two extra parameters [n] and
   [m] give more precise control over hashing. Hashing performs a
   depth-first, right-to-left traversal of the structure [x], stopping
   after [n] meaningful nodes were encountered, or [m] nodes,
   meaningful or not, were encountered. Meaningful nodes are: integers;
   floating-point numbers; strings; characters; booleans; and constant
   constructors. Larger values of [m] and [n] means that more
   nodes are taken into account to compute the final hash
   value, and therefore collisions are less likely to happen.
   However, hashing takes longer. The parameters [m] and [n]
   govern the tradeoff between accuracy and speed. *)

