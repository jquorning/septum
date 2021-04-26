with Ada.Directories.Hierarchical_File_Names;
with Ada.Strings.Unbounded.Text_IO;
with Ada.Text_IO;

package body SP.Contexts is
    function Uses_Extension(Ctx : Context; Extension : String) return Boolean is
        -- Returns true if the context should contain files with the given extension.
    begin
        return Ctx.Extensions.Contains(Ada.Strings.Unbounded.To_Unbounded_String(Extension));
    end Uses_Extension;

    function Add_To_Context(Ctx : in out Context; Next_Entry : Ada.Directories.Directory_Entry_Type) return Boolean is
        use Ada.Directories;
    begin
        if Ada.Directories.Kind (Next_Entry) = Ada.Directories.Ordinary_File and Uses_Extension(Ctx, Ada.Directories.Extension(Ada.Directories.Simple_Name(Next_Entry))) then
            declare
                Lines : String_Vectors.Vector := String_Vectors.Empty_Vector;
            begin
                if Read_Lines(Ada.Directories.Full_Name(Next_Entry), Lines) then
                    if Ctx.Files.Contains
                        (Ada.Strings.Unbounded.To_Unbounded_String
                             (Ada.Directories.Full_Name (Next_Entry)))
                    then
                        Ctx.Files.Replace
                            (Ada.Strings.Unbounded.To_Unbounded_String
                                 (Ada.Directories.Full_Name (Next_Entry)),
                             Lines);
                    else
                        Ctx.Files.Insert
                            (Ada.Strings.Unbounded.To_Unbounded_String (Ada.Directories.Full_Name (Next_Entry)),
                             Lines);
                    end if;
                    Ada.Text_IO.Put_Line ("Next File is: " & Ada.Directories.Full_Name (Next_Entry));
                else
                    return False;
                end if;
            end;
        end if;

        if Ada.Directories.Kind (Next_Entry) = Ada.Directories.Directory
            and then not Refresh (Ctx, Ada.Strings.Unbounded.To_Unbounded_String (Ada.Directories.Full_Name (Next_Entry)))
        then
            return False;
        end if;
        return True;
    end Add_To_Context;


    function Is_Current_Or_Parent_Directory(Dir_Entry : Ada.Directories.Directory_Entry_Type) return Boolean is
        -- Return true if the entry is "." or "..".
        Name : constant String := Ada.Directories.Simple_Name(Dir_Entry);
    begin
        return Ada.Directories.Hierarchical_File_Names.Is_Parent_Directory_Name(Name) or else
            Ada.Directories.Hierarchical_File_Names.Is_Current_Directory_Name(Name);
    end Is_Current_Or_Parent_Directory;

    function Refresh
        (Ctx : in out Context; Starting_Dir : Ada.Strings.Unbounded.Unbounded_String)
          return Boolean is
        --  Refreshes the list of files stored in the context.
        use Ada.Directories;
        Search     : Search_Type;
        Next_Entry : Directory_Entry_Type;
        Filter     : constant Filter_Type := (Ordinary_File | Directory => True, others => False);
    begin
        Ada.Directories.Start_Search
            (Search  => Search, Directory => Ada.Strings.Unbounded.To_String (Starting_Dir),
             Pattern => "*", Filter => Filter);
        while Ada.Directories.More_Entries (Search) loop
            Ada.Directories.Get_Next_Entry (Search, Next_Entry);
            if Is_Current_Or_Parent_Directory(Next_Entry) then
                null;
            elsif not Add_To_Context(Ctx, Next_Entry) then
                return False;
            end if;
        end loop;
        End_Search (Search);
        return True;
    exception
        when others =>
            Ada.Text_IO.Put_Line ("Unknown Exception");
            return False;
    end Refresh;

    function List (Ctx : in Context) return Boolean is
    begin
        for Elem in Ctx.Files.Iterate loop
            Ada.Text_IO.Put_Line (Ada.Strings.Unbounded.To_String(File_Maps.Key (Elem)) & " : " & Integer'Image(Integer(File_Maps.Element(Elem).Length)));
        end loop;
        return True;
    end List;

    function Add_Extensions (Ctx : in out Context; Extensions : in String_Vectors.Vector) return Boolean is
    begin
        for Ext of Extensions loop
            if not Ctx.Extensions.Contains(Ext) then
                Ctx.Extensions.Append(Ext);
            end if;
        end loop;

        Ada.Text_IO.Put_Line("Extensions:");
        for Ext of Ctx.Extensions loop
            Ada.Strings.Unbounded.Text_IO.Put_Line(Ext);
        end loop;
        return True;
    end Add_Extensions;


end SP.Contexts;