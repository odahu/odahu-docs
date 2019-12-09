=============
Metrics
=============

Odahu is pluggable and can integrate with a variety of metrics monitoring tools, allowing monitoring for:

* Model training metrics
* Model performance metrics
* System metrics (e.g. operator counters)

Odahu's installation :ref:`Helm chart <installation-helm>` boostraps a `Prometheus <https://prometheus.io/>`_ operator
to persist metrics and `Grafana <https://grafana.com/>`_ dashboard to display them.

Alternative integrations can be similarly constructed that swap in other monitoring solutions.
