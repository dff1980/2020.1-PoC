#!/bin/bash
kubectl get nodes -o name | xargs -I{} kubectl uncordon {}
