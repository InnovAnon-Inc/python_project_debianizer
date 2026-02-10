#! /usr/bin/env python

import uvicorn

from python_project_debianizer.python_project_debianizer import app

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9322) # TODO get from env
