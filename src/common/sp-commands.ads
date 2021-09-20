-------------------------------------------------------------------------------
-- Copyright 2021, The Septum Developers (see AUTHORS file)

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-------------------------------------------------------------------------------

with Ada.Strings.Unbounded;

with SP.Searches;
with SP.Strings;            use SP.Strings;

package SP.Commands is
    pragma Elaborate_Body;

    use type Ada.Strings.Unbounded.Unbounded_String;

    function Is_Command (S : String) return Boolean;
    function Is_Like_Command (S : String) return Boolean;

    function Target_Command (Command_Name : Ada.Strings.Unbounded.Unbounded_String) return Ada.Strings.Unbounded.Unbounded_String
        with Post => Target_Command'Result = Ada.Strings.Unbounded.Null_Unbounded_String
            or else Is_Command (Ada.Strings.Unbounded.To_String (Target_Command'Result));

    type Command_Result is (Command_Success, Command_Failed, Command_Unknown, Command_Exit_Requested);

    function Run_Commands_From_File (Srch : in out SP.Searches.Search; File : String) return Command_Result;
    function Execute (Srch : in out SP.Searches.Search; Command_Line : in String_Vectors.Vector) return Command_Result;

end SP.Commands;