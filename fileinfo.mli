(** Fileinfo: File generation documentation keeper.

   Copyright Luca de Alfaro <lda@dealfaro.org>, 2008.
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

(** The goal of this module is to associate with every file foo , a
    file foo.info.xml which contains detailed information on how foo
    was produced.  Specifically, each file that is output is
    associated with a tag, that indicates the command-line and time at
    which the command used to produce it was issued, as well as all
    the information gathered from input files that were read before
    the output file was closed.
 *)

(** There is a default information object, but if you want to pass it 
    version information, and additional information, then do: 
    [make_info_obj version_string extra_string]. *)
val make_info_obj : string -> string -> unit

(** Opens a file for reading, reading also its information *)
val open_info_in : string -> in_channel

(** Not all files are opened via open_info_in.  This function
    is used to manually add extra files to be tracked. *)
val track_file : string -> unit

(** Closes a file for reading *)
val close_info_in : in_channel -> unit

(** Opens a file for output. *)
val open_info_out : string -> out_channel

(* Closes a file for output, writing at the end also the xml information *)
val close_info_out : out_channel -> unit

(* Gives me an xml string that summarizes all that has happened *)
val make_xml_string : unit -> string
