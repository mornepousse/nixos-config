{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Compatibilité pour vieux binaires (ex: PerformanceTest)
    ncurses5

    # Outils de benchmark
    sysbench
    geekbench
    stress-ng
    fio             # Benchmark I/O disque
    iperf3          # Benchmark réseau
  ];
}
