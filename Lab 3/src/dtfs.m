function a = dtfs(x, n_init)
    a = DTS({n_init, n_init + length(x) - 1}, x).dtfs;
end
