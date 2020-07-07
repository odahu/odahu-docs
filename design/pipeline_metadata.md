# ML Pipeline and ML Metadata relations

In this document we describe general overview of relations between
ML Pipeline Service and ML Metadata Service

## Terms

*ML Pipeline* is any service that allows describing sequence of steps
that should be executed together in some order to get ML Artifact (Usually ML Model)

Pipeline services that are developed with ML specifics in mind
* Azure ML
* Kubeflow

Pipeline services that are developed w/o ML specifics in mind
* Jenkins
* Airflow

## 
