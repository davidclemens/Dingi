function row = table2emptyRow(tbl)

    % make use of Matlab calling class constructors without arguments for
    % tbl(end + 1,:).
    tbl(end + 2,:)  = tbl(1,:);
    row             = tbl(end - 1,:);
end