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

(* Name of the info extension *)
let info_ext = ".info.xml"

class file_info
  (version: string) (* version of code producing the output *)
  (extra_info: string) (* anything goes *)
  = 
  let time_pm = Unix.gmtime (Unix.time ()) in 
  let time_str = Printf.sprintf "%4dy%02dm%02dd %02d:%02d:%02d GMT" (time_pm.Unix.tm_year + 1900) (time_pm.Unix.tm_mon + 1) time_pm.Unix.tm_mday time_pm.Unix.tm_hour time_pm.Unix.tm_min time_pm.Unix.tm_sec in 
  let cmd_line = String.concat " " (Array.to_list Sys.argv) in 
  let my_info = 
        [("Command", cmd_line); 
	 ("Version", version);
         ("Info", extra_info); 
	 ("Date", time_str)] in 
object (self)

  (* Here we store the info on the files we have read as input *)
  val mutable input_info : Xml.xml list = []
  (* Hash table to store the names of open files *)
  val file_names : (out_channel, string) Hashtbl.t = Hashtbl.create 10

  (* Tracks one more input file *)
  method m_track_input_file (f_name: string) : unit = 
    let info_file_name = f_name ^ info_ext in 
    (* Parses the xml file.  I don't want errors here: I don't want
       to break the main process for lack of .xml data. *)
    let xml_in = try 
      Some (Xml.parse_file info_file_name) 
    with _ -> None 
    in 
    (* We need to add the file name, as this is always available. *)
    let xml_file = begin 
      match xml_in with 
	Some x -> Xml.Element ("InputFile", [("Name", f_name)], [x])
      | None -> Xml.Element ("InputFile", [("Name", f_name)], [])
    end in 
    (* Adds this information about the input to the rest of the information. *)
    input_info <- input_info @ [xml_file]

  (* Opens a file, collecting the xml info if present *)
  method m_open_info_in (f_name: string) : in_channel = 
    (* Opens the real file *)
    let fp = open_in f_name in 
    self#m_track_input_file f_name; 
    fp

  (* Closes a file for input *)
  method m_close_info_in (fp: in_channel) = close_in_noerr fp

  (* Opens a file for output.  We need to remember the name for later on. *)
  method m_open_info_out (f_name: string) : out_channel = 
    let fp = open_out f_name in 
    Hashtbl.add file_names fp f_name; fp

  (* Produces a string representative of what has happened up to this moment *)
  method m_make_xml_string (): string = 
    let xml_out_el = Xml.Element ("Process", my_info, input_info) in 
    Xml.to_string_fmt xml_out_el

  (* Closes a file for output, and writes the information about how the file
     was produced. *)
  method m_close_info_out (fp: out_channel) = 
    (* Retrieves the file name *)
    let file_name_opt =
      try 
	Some (Hashtbl.find file_names fp) 
      with Not_found -> None 
    in 
    (* Closes the output file *)
    close_out fp; 
    (* If we have a file name, which should be the case, we produce
       the .info.xml file *)
    begin 
      match file_name_opt with 
	None -> ()
      | Some n -> begin 
	  (* Yes, we have the name of the info file. *)
	  let info_file_n = n ^ info_ext in 
	  let info_fp = open_out info_file_n in 
	  output_string info_fp (self#m_make_xml_string ());
	  close_out_noerr info_fp
	end
    end

end (* class *)

(* The following functions are used to avoid having to pass the object
   around all the time. *)
let info_obj = ref (new file_info "" "")

let make_info_obj (version: string) (extra_info: string) : unit = 
  info_obj := new file_info version extra_info

(* Note: "let open_info_in = !info_obj#m_open_info_in" does not work, 
   as the function is statiscally bound to the method of the ORIGINAL 
   object. *)
let open_info_in f = !info_obj#m_open_info_in f
let track_file f = !info_obj#m_track_input_file f 
let close_info_in f = !info_obj#m_close_info_in f
let open_info_out f = !info_obj#m_open_info_out f
let close_info_out f = !info_obj#m_close_info_out f
let make_xml_string () = !info_obj#m_make_xml_string ()
