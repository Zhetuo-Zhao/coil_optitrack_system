function falling_edges = findFallingEdges(data)
%Finds rising edges in logical data
    edge_diff = diff(data);
    % compute rising edges
    falling_edges = find(edge_diff == 1) + 1; % add one t o the indices to account for diff loss
end
