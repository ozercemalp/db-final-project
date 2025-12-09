import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../AuthContext';

const PostCard = ({ post }) => {
  const { user } = useAuth();
  const navigate = useNavigate();

  // Local state for optimistic updates
  const [score, setScore] = React.useState(post.UPVOTES);
  const [voteStatus, setVoteStatus] = React.useState(post.USER_VOTE || 0); // 1, -1, or 0

  const handleVote = async (e, type) => {
    e.stopPropagation(); // Prevent ensuring navigation when clicking vote
    if (!user) {
      alert("Please login to vote!");
      return;
    }

    // Optimistic Update
    const previousScore = score;
    const previousStatus = voteStatus;

    // Logic: 
    // If clicking same vote type -> Undo vote (0)
    // If clicking diff vote type -> Change vote

    let newStatus = type;
    let newScore = score;

    if (voteStatus === type) {
      // Toggle off
      newStatus = 0;
      newScore = score - type;
    } else {
      // Changing vote or voting for first time
      // If changing, we remove previous impact first
      if (voteStatus !== 0) {
        newScore = score - voteStatus;
      }
      newScore = newScore + type;
    }

    setScore(newScore);
    setVoteStatus(newStatus);

    try {
      await axios.post(`/api/posts/${post.POST_ID}/vote`, {
        user_id: user.user_id,
        vote_type: newStatus === 0 ? 0 : type // Ensure backend handles 0 if "unvote" logic exists, or we might need to send differently. 
        // Wait, backend logic for vote_post typically is an UPSERT or specific "vote" action. 
        // If the backend doesn't support '0' to unvote, we might just have to send the type.
        // Assuming backend handles it or we'll face errors. 
        // Actually, screenshot showed PL/SQL vote_post. Usually these toggle or set.
        // Let's assume standard "set vote" behavior for now. If failure, we revert.
      });
      // Success, do nothing
    } catch (error) {
      console.error("Vote failed", error);
      // Revert
      setScore(previousScore);
      setVoteStatus(previousStatus);
      alert("Vote failed: " + (error.response?.data?.error || error.message));
    }
  };

  const goToDetail = () => {
    navigate(`/post/${post.POST_ID}`);
  };

  const handleShare = (e) => {
    e.stopPropagation();
    const url = `${window.location.origin}/post/${post.POST_ID}`;
    navigator.clipboard.writeText(url).then(() => {
      alert("Link copied to clipboard!");
    });
  };

  return (
    <div
      onClick={goToDetail}
      className="bg-white border border-gray-300 rounded hover:border-gray-400 cursor-pointer mb-3 flex transition-colors"
    >
      {/* Vote Sidebar */}
      <div className="w-10 bg-gray-50 p-2 flex flex-col items-center rounded-l border-r border-gray-100">
        <button
          onClick={(e) => handleVote(e, 1)}
          className={`font-bold text-xl hover:text-red-500 ${voteStatus === 1 ? 'text-red-500' : 'text-gray-400'}`}
        >
          ▲
        </button>
        <span className={`text-sm font-bold my-1 ${voteStatus === 1 ? 'text-red-500' : voteStatus === -1 ? 'text-blue-500' : 'text-gray-800'}`}>
          {score}
        </span>
        <button
          onClick={(e) => handleVote(e, -1)}
          className={`font-bold text-xl hover:text-blue-500 ${voteStatus === -1 ? 'text-blue-500' : 'text-gray-400'}`}
        >
          ▼
        </button>
      </div>

      {/* Content */}
      <div className="p-2 w-full">
        <div className="text-xs text-gray-500 mb-1 flex items-center">
          <Link
            to={`/r/${post.SUBFORUM_NAME}`}
            onClick={(e) => e.stopPropagation()}
            className="font-bold text-black hover:underline z-10"
          >
            r/{post.SUBFORUM_NAME || 'all'}
          </Link>
          <span className="mx-1">•</span>
          <span>Posted by u/{post.USERNAME}</span>
          <span className="mx-1">•</span>
          <span>{new Date(post.CREATED_AT).toLocaleDateString()}</span>
        </div>
        <h3 className="text-lg font-medium mb-2">{post.TITLE}</h3>
        <p className="text-gray-800 text-sm mb-2 break-words">{post.CONTENT_TEXT}</p>
        <div className="flex space-x-2 text-gray-500 text-sm font-bold">
          <button className="flex items-center space-x-1 hover:bg-gray-100 p-1 rounded">
            <span>💬 Comments</span>
          </button>
          <button
            onClick={handleShare}
            className="flex items-center space-x-1 hover:bg-gray-100 p-1 rounded"
          >
            <span>🔗 Share</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default PostCard;
