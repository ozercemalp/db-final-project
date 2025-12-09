import React, { useEffect, useState } from 'react';
import axios from 'axios';
import PostCard from '../components/PostCard';
import { useAuth } from '../AuthContext';

const Home = () => {
  const { user } = useAuth(); // Put this at the top
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPosts = async () => {
      try {
        const userIdParam = user ? `?current_user_id=${user.user_id}` : '';
        const res = await axios.get(`/api/posts${userIdParam}`);
        setPosts(res.data);
      } catch (err) {
        console.error("Failed to fetch posts", err);
      } finally {
        setLoading(false);
      }
    };
    fetchPosts();
  }, []);

  return (
    <div className="container mx-auto py-4 px-2 md:px-0 flex justify-center">
      <div className="w-full md:w-2/3 lg:w-1/2">
        <h1 className="text-xl font-bold mb-4">Popular Posts</h1>
        {loading ? (
          <p>Loading...</p>
        ) : (
          posts.map(post => <PostCard key={post.POST_ID} post={post} />)
        )}
      </div>
      {/* Sidebar Placeholder */}
      <div className="hidden md:block w-1/3 ml-4">
        <div className="bg-white border border-gray-300 p-4 rounded mb-4">
          <h2 className="font-bold mb-2">About Community</h2>
          <p className="text-sm text-gray-600">Welcome to ShareIt, the front page of the internet imitation.</p>
        </div>
      </div>
    </div>
  );
};

export default Home;
