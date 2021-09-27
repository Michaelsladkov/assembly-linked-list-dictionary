%macro colon 2
    %ifid %2
        %2:
        %ifdef NEXT_ELEM
            .next: dq NEXT_ELEM
        %else
            .next: dq 0
        %endif
        %define NEXT_ELEM %2
        .key: db %1
        .value:
    %else
        %fatal "Not correct label"
    %endif
%endmacro