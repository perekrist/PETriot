from aiohttp_plugin import BaseModel
from typing import Optional, List


class Proposal(BaseModel):
    latitude: float
    longitude: float
    author: Optional[str] = None
    tags: List[int] = []
    description: Optional[str] = None
    attachments: List[str] = []
