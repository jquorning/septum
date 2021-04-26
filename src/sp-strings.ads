with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package SP.Strings is
    package String_Vectors is new Ada.Containers.Vectors(Index_Type   => Positive,
                                                         Element_Type => Ada.Strings.Unbounded.Unbounded_String,
                                                         "="          => Ada.Strings.Unbounded."=");

    function Split (S : Ada.Strings.Unbounded.Unbounded_String) return String_Vectors.Vector;

    function Read_Lines (File_Name : String; Result : out String_Vectors.Vector) return Boolean;
end SP.Strings;