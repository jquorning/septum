with Ada.Directories.Hierarchical_File_Names;
with Ada.Strings.Unbounded;

package body SP.File_System is

    function Is_Current_Or_Parent_Directory (Dir_Entry : Ada.Directories.Directory_Entry_Type) return Boolean is
        --  Return true if the entry is "." or "..".
        Name : constant String := Ada.Directories.Simple_Name (Dir_Entry);
    begin
        return
            Ada.Directories.Hierarchical_File_Names.Is_Parent_Directory_Name (Name)
            or else Ada.Directories.Hierarchical_File_Names.Is_Current_Directory_Name (Name);
    end Is_Current_Or_Parent_Directory;

   function Contents (Dir_Name : String) return Dir_Contents is
        use Ada.Directories;
        Dir_Search : Search_Type;
        Next_Entry : Directory_Entry_Type;
        Filter     : constant Filter_Type := (Ordinary_File | Directory => True, others => False);
    begin
        return Result : Dir_Contents do
            Ada.Directories.Start_Search
                (Search => Dir_Search, Directory => Dir_Name, Pattern => "*", Filter => Filter);
            while More_Entries (Dir_Search) loop
                Get_Next_Entry (Dir_Search, Next_Entry);
                if not Is_Current_Or_Parent_Directory (Next_Entry) then
                    case Kind (Next_Entry) is
                        when Directory => Result.Subdirs.Append (Ada.Strings.Unbounded.To_Unbounded_String(Full_Name (Next_Entry)));
                        when Ordinary_File => Result.Files.Append (Ada.Strings.Unbounded.To_Unbounded_String(Full_Name (Next_Entry)));
                            when others => null;
                    end case;
                end if;
            end loop;
            End_Search (Dir_Search);
        end return;
    end Contents;


end SP.File_System;