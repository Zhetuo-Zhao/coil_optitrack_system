function rising_edges = findRisingEdges(data)
%Finds rising edges in logical data
    edge_diff = diff(data);
    % compute rising edges
    rising_edges = find(edge_diff == 1) + 1; % add one to the indices to account for diff loss
end
